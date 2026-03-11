import 'package:hive_flutter/hive_flutter.dart';

/// Hive boxes for session caching
class HiveBoxes {
  static const String sessionBox = 'session';
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';

  /// Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Open boxes
    await Hive.openBox(sessionBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox(cacheBox);
  }

  /// Get session box
  static Box get session => Hive.box(sessionBox);

  /// Get settings box
  static Box get settings => Hive.box(settingsBox);

  /// Get cache box
  static Box get cache => Hive.box(cacheBox);

  /// Clear all boxes
  static Future<void> clearAll() async {
    await session.clear();
    await settings.clear();
    await cache.clear();
  }

  /// Session box methods
  static Future<void> saveToken(String token) async {
    await session.put('auth_token', token);
  }

  static String? getToken() {
    return session.get('auth_token');
  }

  static Future<void> savePhoneHash(String hash) async {
    await session.put('phone_hash', hash);
  }

  static String? getPhoneHash() {
    return session.get('phone_hash');
  }

  static Future<void> saveLearnerId(String id) async {
    await session.put('learner_id', id);
  }

  static String? getLearnerId() {
    return session.get('learner_id');
  }

  /// Settings box methods
  static Future<void> saveSetting(String key, dynamic value) async {
    await settings.put(key, value);
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    return settings.get(key, defaultValue: defaultValue) as T?;
  }

  /// Onboarding state
  static Future<void> setOnboardingComplete(bool complete) async {
    await settings.put('onboarding_complete', complete);
  }

  static bool isOnboardingComplete() {
    return settings.get('onboarding_complete', defaultValue: false) as bool;
  }

  /// Displacement context
  static Future<void> setDisplacementContext(String context) async {
    await settings.put('displacement_context', context);
  }

  static String? getDisplacementContext() {
    return settings.get('displacement_context');
  }

  /// Preferred language
  static Future<void> setPreferredLanguage(String language) async {
    await settings.put('preferred_language', language);
  }

  static String getPreferredLanguage() {
    return settings.get('preferred_language', defaultValue: 'en') as String;
  }

  /// Last sync time
  static Future<void> setLastSyncTime(int timestamp) async {
    await settings.put('last_sync_time', timestamp);
  }

  static int? getLastSyncTime() {
    return settings.get('last_sync_time');
  }
}
