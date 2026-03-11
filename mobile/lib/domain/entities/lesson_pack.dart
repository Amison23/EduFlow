/// Lesson Pack entity
class LessonPack {
  final String id;
  final String subject;
  final int level;
  final String language;
  final int version;
  final double? sizeMb;
  final String? storagePath;
  final DateTime publishedAt;

  const LessonPack({
    required this.id,
    required this.subject,
    required this.level,
    required this.language,
    this.version = 1,
    this.sizeMb,
    this.storagePath,
    required this.publishedAt,
  });

  factory LessonPack.fromJson(Map<String, dynamic> json) {
    return LessonPack(
      id: json['id'] as String,
      subject: json['subject'] as String,
      level: json['level'] as int,
      language: json['language'] as String,
      version: json['version'] as int? ?? 1,
      sizeMb: (json['size_mb'] as num?)?.toDouble(),
      storagePath: json['storage_path'] as String?,
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'level': level,
      'language': language,
      'version': version,
      'size_mb': sizeMb,
      'storage_path': storagePath,
      'published_at': publishedAt.toIso8601String(),
    };
  }

  String get displayTitle {
    final subjectName = subject[0].toUpperCase() + subject.substring(1);
    return '$subjectName - Level $level';
  }

  bool get isDownloaded => storagePath != null;
}
