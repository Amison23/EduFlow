part of 'progress_bloc.dart';

abstract class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

class LoadProgress extends ProgressEvent {
  const LoadProgress();
}

class LogProgress extends ProgressEvent {
  final String lessonId;
  final String eventType;
  final double? score;

  const LogProgress({
    required this.lessonId,
    required this.eventType,
    this.score,
  });

  @override
  List<Object?> get props => [lessonId, eventType, score];
}
