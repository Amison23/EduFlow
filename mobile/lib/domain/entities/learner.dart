/// Learner entity
class Learner {
  final String id;
  final String phoneHash;
  final String? region;
  final String? displacement;
  final String language;
  final DateTime createdAt;

  const Learner({
    required this.id,
    required this.phoneHash,
    this.region,
    this.displacement,
    this.language = 'en',
    required this.createdAt,
  });

  factory Learner.fromJson(Map<String, dynamic> json) {
    return Learner(
      id: json['id'] as String,
      phoneHash: json['phone_hash'] as String,
      region: json['region'] as String?,
      displacement: json['displacement'] as String?,
      language: json['language'] as String? ?? 'en',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_hash': phoneHash,
      'region': region,
      'displacement': displacement,
      'language': language,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Learner copyWith({
    String? id,
    String? phoneHash,
    String? region,
    String? displacement,
    String? language,
    DateTime? createdAt,
  }) {
    return Learner(
      id: id ?? this.id,
      phoneHash: phoneHash ?? this.phoneHash,
      region: region ?? this.region,
      displacement: displacement ?? this.displacement,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
