/// Lesson entity
class Lesson {
  final String id;
  final String packId;
  final int sequence;
  final String title;
  final String? content;
  final String? audioUrl;
  final int? durationMins;

  const Lesson({
    required this.id,
    required this.packId,
    required this.sequence,
    required this.title,
    this.content,
    this.audioUrl,
    this.durationMins,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      packId: json['pack_id'] as String,
      sequence: json['sequence'] as int,
      title: json['title'] as String,
      content: json['content'] as String?,
      audioUrl: json['audio_url'] as String?,
      durationMins: json['duration_mins'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pack_id': packId,
      'sequence': sequence,
      'title': title,
      'content': content,
      'audio_url': audioUrl,
      'duration_mins': durationMins,
    };
  }

  Lesson copyWith({
    String? id,
    String? packId,
    int? sequence,
    String? title,
    String? content,
    String? audioUrl,
    int? durationMins,
  }) {
    return Lesson(
      id: id ?? this.id,
      packId: packId ?? this.packId,
      sequence: sequence ?? this.sequence,
      title: title ?? this.title,
      content: content ?? this.content,
      audioUrl: audioUrl ?? this.audioUrl,
      durationMins: durationMins ?? this.durationMins,
    );
  }
}
