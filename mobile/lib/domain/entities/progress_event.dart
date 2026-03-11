/// Progress Event entity
class ProgressEvent {
  final String id;
  final String learnerId;
  final String lessonId;
  final String eventType;
  final double? score;
  final DateTime deviceTimestamp;
  final DateTime? serverTimestamp;
  final Map<String, dynamic>? metadata;
  final bool synced;

  const ProgressEvent({
    required this.id,
    required this.learnerId,
    required this.lessonId,
    required this.eventType,
    this.score,
    required this.deviceTimestamp,
    this.serverTimestamp,
    this.metadata,
    this.synced = false,
  });

  factory ProgressEvent.fromJson(Map<String, dynamic> json) {
    return ProgressEvent(
      id: json['id'] as String,
      learnerId: json['learner_id'] as String,
      lessonId: json['lesson_id'] as String,
      eventType: json['event_type'] as String,
      score: (json['score'] as num?)?.toDouble(),
      deviceTimestamp: DateTime.fromMillisecondsSinceEpoch(json['device_ts'] as int),
      serverTimestamp: json['server_ts'] != null 
          ? DateTime.parse(json['server_ts'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      synced: json['synced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'learner_id': learnerId,
      'lesson_id': lessonId,
      'event_type': eventType,
      'score': score,
      'device_ts': deviceTimestamp.millisecondsSinceEpoch,
      'server_ts': serverTimestamp?.toIso8601String(),
      'metadata': metadata,
    };
  }

  bool get isLessonStart => eventType == 'lesson_started';
  bool get isLessonComplete => eventType == 'lesson_completed';
  bool get isQuizCompleted => eventType == 'quiz_completed';

  ProgressEvent copyWith({
    String? id,
    String? learnerId,
    String? lessonId,
    String? eventType,
    double? score,
    DateTime? deviceTimestamp,
    DateTime? serverTimestamp,
    Map<String, dynamic>? metadata,
    bool? synced,
  }) {
    return ProgressEvent(
      id: id ?? this.id,
      learnerId: learnerId ?? this.learnerId,
      lessonId: lessonId ?? this.lessonId,
      eventType: eventType ?? this.eventType,
      score: score ?? this.score,
      deviceTimestamp: deviceTimestamp ?? this.deviceTimestamp,
      serverTimestamp: serverTimestamp ?? this.serverTimestamp,
      metadata: metadata ?? this.metadata,
      synced: synced ?? this.synced,
    );
  }
}

/// Event types
class EventTypes {
  static const String lessonStarted = 'lesson_started';
  static const String lessonCompleted = 'lesson_completed';
  static const String quizAnswered = 'quiz_answered';
  static const String quizCompleted = 'quiz_completed';
  static const String lessonDownloaded = 'lesson_downloaded';
  static const String appOpened = 'app_opened';
}
