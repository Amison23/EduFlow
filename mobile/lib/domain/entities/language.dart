class Language {
  final String id;
  final String code;
  final String name;
  final bool isActive;

  const Language({
    required this.id,
    required this.code,
    required this.name,
    this.isActive = true,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'is_active': isActive,
    };
  }

  String get flag {
    switch (code) {
      case 'en':
        return '🇺🇸';
      case 'sw':
        return '🇰🇪';
      case 'am':
        return '🇪🇹';
      case 'so':
        return '🇸🇴';
      default:
        return '🌍';
    }
  }
}
