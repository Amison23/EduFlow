import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/lesson_repository.dart';

part 'lesson_event.dart';
part 'lesson_state.dart';

/// BLoC for lessons
class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final LessonRepository _lessonRepository;

  LessonBloc({required LessonRepository lessonRepository})
      : _lessonRepository = lessonRepository,
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
    
    final result = await _lessonRepository.getLessonPacks();
    
    if (result.failure != null) {
      emit(LessonError(result.failure!.message));
    } else {
      emit(LessonPacksLoaded(result.packs));
    }
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
