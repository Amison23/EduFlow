part of 'lesson_bloc.dart';

/// Base class for lesson events
abstract class LessonEvent {
  const LessonEvent();
}

/// Load all lesson packs
class LoadLessonPacks extends LessonEvent {
  final String? language;

  const LoadLessonPacks({this.language});
}

/// Load lessons for a specific pack
class LoadLessonsForPack extends LessonEvent {
  final String packId;

  const LoadLessonsForPack(this.packId);
}

/// Download a lesson pack
class DownloadPack extends LessonEvent {
  final String packId;

  const DownloadPack(this.packId);
}

/// Load a specific lesson
class LoadLesson extends LessonEvent {
  final String lessonId;

  const LoadLesson(this.lessonId);
}

/// Load quiz questions for a lesson
class LoadQuizQuestions extends LessonEvent {
  final String lessonId;

  const LoadQuizQuestions(this.lessonId);
}

/// Load adaptive quiz based on learner performance
class LoadAdaptiveQuiz extends LessonEvent {
  final String learnerId;
  final String subject;
  final int count;

  const LoadAdaptiveQuiz({
    required this.learnerId,
    required this.subject,
    this.count = 5,
  });
}
