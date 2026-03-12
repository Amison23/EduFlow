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
  final bool isLocked;

  const LessonPack({
    required this.id,
    required this.subject,
    required this.level,
    required this.language,
    this.version = 1,
    this.sizeMb,
    this.storagePath,
    required this.publishedAt,
    this.isLocked = false,
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
      isLocked: json['is_locked'] as bool? ?? false,
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
      'is_locked': isLocked,
    };
  }

  LessonPack copyWith({
    String? id,
    String? subject,
    int? level,
    String? language,
    int? version,
    double? sizeMb,
    String? storagePath,
    DateTime? publishedAt,
    bool? isLocked,
  }) {
    return LessonPack(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      level: level ?? this.level,
      language: language ?? this.language,
      version: version ?? this.version,
      sizeMb: sizeMb ?? this.sizeMb,
      storagePath: storagePath ?? this.storagePath,
      publishedAt: publishedAt ?? this.publishedAt,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  String get displayTitle {
    final subjectName = subject[0].toUpperCase() + subject.substring(1);
    return '$subjectName - Level $level';
  }

  bool get isDownloaded => storagePath != null;
}
