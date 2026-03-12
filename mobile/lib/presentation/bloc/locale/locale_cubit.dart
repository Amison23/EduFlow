import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/auth_repository.dart';

/// Cubit for managing the app's locale (language)
class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'app_locale';
  final AuthRepository _authRepository;

  LocaleCubit({required AuthRepository authRepository}) 
      : _authRepository = authRepository,
        super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      emit(Locale(languageCode));
    }
  }

  Future<void> setLocale(String languageCode) async {
    final newLocale = Locale(languageCode);
    emit(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    
    // Sync to backend if possible
    await _authRepository.syncPreferredLanguage(languageCode);
  }

  static String getLanguageName(String code) {
    switch (code) {
      case 'sw':
        return 'Swahili';
      case 'am':
        return 'Amharic';
      case 'so':
        return 'Somali';
      default:
        return 'English';
    }
  }
}
