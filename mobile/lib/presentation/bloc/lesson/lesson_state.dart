part of 'lesson_bloc.dart';

/// Base class for lesson states
abstract class LessonState {
  const LessonState();
}

/// Initial state
class LessonInitial extends LessonState {}

/// Loading state
class LessonLoading extends LessonState {}

/// Lesson packs loaded
class LessonPacksLoaded extends LessonState {
  final List<Map<String, dynamic>> packs;

  const LessonPacksLoaded(this.packs);
}

/// Lessons loaded for a pack
class LessonsLoaded extends LessonState {
  final List<Map<String, dynamic>> lessons;
  final String packId;

  const LessonsLoaded(this.lessons, this.packId);
}

/// Single lesson loaded
class SingleLessonLoaded extends LessonState {
  final Map<String, dynamic> lesson;

  const SingleLessonLoaded(this.lesson);
}

/// Quiz loaded
class QuizLoaded extends LessonState {
  final List<Map<String, dynamic>> questions;

  const QuizLoaded(this.questions);
}

/// Pack downloading
class PackDownloading extends LessonState {
  final String packId;
  final double progress;

  const PackDownloading(this.packId, this.progress);
}

/// Pack downloaded
class PackDownloaded extends LessonState {
  final String packId;

  const PackDownloaded(this.packId);
}

/// Error state
class LessonError extends LessonState {
  final String message;

  const LessonError(this.message);
}
