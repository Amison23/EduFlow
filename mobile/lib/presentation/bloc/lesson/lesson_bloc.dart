import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../../../data/repositories/progress_repository.dart';

part 'lesson_event.dart';
part 'lesson_state.dart';

/// BLoC for lessons
class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final LessonRepository _lessonRepository;
  final ProgressRepository _progressRepository;

  LessonBloc({
    required LessonRepository lessonRepository,
    required ProgressRepository progressRepository,
  })  : _lessonRepository = lessonRepository,
        _progressRepository = progressRepository,
        super(LessonInitial()) {
    on<LoadLessonPacks>(_onLoadLessonPacks);
    on<LoadLessonsForPack>(_onLoadLessonsForPack);
    on<DownloadPack>(_onDownloadPack);
    on<LoadLesson>(_onLoadLesson);
    on<LoadQuizQuestions>(_onLoadQuizQuestions);
    on<LoadAdaptiveQuiz>(_onLoadAdaptiveQuiz);
  }

  Future<void> _onLoadLessonPacks(
    LoadLessonPacks event,
    Emitter<LessonState> emit,
  ) async {
    emit(LessonLoading());
    
    // 1. Fetch packs
    final packsResult = await _lessonRepository.getLessonPacks(language: event.language);
    
    if (packsResult.failure != null) {
      emit(LessonError(packsResult.failure!.message));
      return;
    }

    // 2. Fetch progress to determine locking
    final progressResult = await _progressRepository.getProgress();
    final List<dynamic> events = (progressResult.progress?['events'] as List?) ?? [];
    
    // Identify packs that have at least one completed lesson
    final completedPackIds = <String>{};
    for (var event in events) {
      final type = event['event_type'] as String?;
      if (type == 'quiz_completed' || type == 'lesson_completed') {
        // The pack_id is nested in the lessons object from the join
        final lessons = event['lessons'] as Map<String, dynamic>?;
        if (lessons != null && lessons['pack_id'] != null) {
          completedPackIds.add(lessons['pack_id'] as String);
        }
      }
    }

    // 3. Process packs with locking logic
    final updatedPacks = <Map<String, dynamic>>[];
    
    // Group packs by subject to check hierarchy within subject
    final subjectPacks = <String, List<Map<String, dynamic>>>{};
    for (var packJson in packsResult.packs) {
      final subject = packJson['subject'] as String;
      subjectPacks.putIfAbsent(subject, () => []).add(packJson);
    }

    for (var subject in subjectPacks.keys) {
      // Sort by level ascending
      final packs = subjectPacks[subject]!..sort((a, b) => (a['level'] as int).compareTo(b['level'] as int));
      
      bool previousLevelCompleted = true; // Level 1 is always unlocked

      for (var i = 0; i < packs.length; i++) {
        final pack = packs[i];
        final level = pack['level'] as int;
        final packId = pack['id'] as String;
        
        // A pack is locked if level > 1 AND the previous level's pack wasn't completed
        bool isLocked = false;
        if (level > 1 && !previousLevelCompleted) {
          isLocked = true;
        }

        // Add back to updated list
        final updatedPack = Map<String, dynamic>.from(pack);
        updatedPack['is_locked'] = isLocked;
        updatedPacks.add(updatedPack);

        // Update completion status for the next level in the same subject
        previousLevelCompleted = completedPackIds.contains(packId);
      }
    }

    emit(LessonPacksLoaded(updatedPacks));
  }

  Future<void> _onLoadLessonsForPack(
    LoadLessonsForPack event,
    Emitter<LessonState> emit,
  ) async {
    emit(LessonLoading());
    
    final result = await _lessonRepository.getLessonsForPack(event.packId);
    
    if (result.failure != null) {
      emit(LessonError(result.failure!.message));
    } else {
      emit(LessonsLoaded(result.lessons, event.packId));
    }
  }

  Future<void> _onDownloadPack(
    DownloadPack event,
    Emitter<LessonState> emit,
  ) async {
    emit(PackDownloading(event.packId, 0));
    
    final result = await _lessonRepository.downloadPack(
      event.packId,
      onProgress: (received, total) {
        if (total > 0) {
          // Progress can be used here if needed: received / total
        }
      },
    );
    
    if (result.success) {
      emit(PackDownloaded(event.packId));
    } else {
      emit(LessonError(result.failure?.message ?? 'Download failed'));
    }
  }

  Future<void> _onLoadLesson(
    LoadLesson event,
    Emitter<LessonState> emit,
  ) async {
    emit(LessonLoading());
    final result = await _lessonRepository.getLesson(event.lessonId);
    
    if (result.failure != null) {
      emit(LessonError(result.failure!.message));
    } else if (result.lesson != null) {
      emit(SingleLessonLoaded(result.lesson!));
    } else {
      emit(const LessonError('Lesson not found'));
    }
  }

  Future<void> _onLoadQuizQuestions(
    LoadQuizQuestions event,
    Emitter<LessonState> emit,
  ) async {
    emit(LessonLoading());
    
    final result = await _lessonRepository.getQuizQuestions(event.lessonId);
    
    if (result.failure != null) {
      emit(LessonError(result.failure!.message));
    } else {
      emit(QuizLoaded(result.questions));
    }
  }

  Future<void> _onLoadAdaptiveQuiz(
    LoadAdaptiveQuiz event,
    Emitter<LessonState> emit,
  ) async {
    emit(LessonLoading());
    
    final result = await _lessonRepository.getAdaptiveQuiz(
      learnerId: event.learnerId,
      subject: event.subject,
      count: event.count,
    );
    
    if (result.failure != null) {
      emit(LessonError(result.failure!.message));
    } else {
      emit(QuizLoaded(result.questions));
    }
  }
}
