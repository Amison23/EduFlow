import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../services/tflite_quiz_service.dart';

part 'progress_event.dart';
part 'progress_state.dart';

/// BLoC for tracking learner progress and stats
class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final ProgressRepository _progressRepository;
  final TfliteQuizService? _quizService;

  ProgressBloc({
    required ProgressRepository progressRepository,
    TfliteQuizService? quizService,
  })  : _progressRepository = progressRepository,
        _quizService = quizService,
        super(ProgressInitial()) {
    on<LoadProgress>(_onLoadProgress);
    on<LogProgress>(_onLogProgress);
  }

  Future<void> _onLoadProgress(
    LoadProgress event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    
    final progressResult = await _progressRepository.getProgress();
    final streakResult = await _progressRepository.getStreak();
    
    if (progressResult.failure != null || streakResult.failure != null) {
      emit(ProgressError(progressResult.failure?.message ?? streakResult.failure?.message ?? 'Failed to load progress'));
    } else {
      // Sync mastery to TfliteQuizService if available
      if (_quizService != null) {
        await _progressRepository.initializeMasteryFromServer(_quizService!);
      }

      emit(ProgressLoaded(
        progress: progressResult.progress ?? {},
        streak: streakResult.streak,
      ));
    }
  }

  Future<void> _onLogProgress(
    LogProgress event,
    Emitter<ProgressState> emit,
  ) async {
    await _progressRepository.logProgressEvent(
      lessonId: event.lessonId,
      eventType: event.eventType,
      score: event.score,
    );
    // Reload progress after logging
    add(const LoadProgress());
  }
}
