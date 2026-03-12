import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/entities/language.dart';

abstract class LanguageState {}

class LanguageInitial extends LanguageState {}
class LanguageLoading extends LanguageState {}
class LanguageLoaded extends LanguageState {
  final List<Language> languages;
  LanguageLoaded(this.languages);
}
class LanguageError extends LanguageState {
  final String message;
  LanguageError(this.message);
}

class LanguageCubit extends Cubit<LanguageState> {
  final AuthRepository _authRepository;

  LanguageCubit({required AuthRepository authRepository}) 
      : _authRepository = authRepository,
        super(LanguageInitial()) {
    fetchLanguages();
  }

  Future<void> fetchLanguages() async {
    emit(LanguageLoading());
    try {
      final data = await _authRepository.getSupportedLanguages();
      final languages = data.map((json) => Language.fromJson(json)).where((l) => l.isActive).toList();
      
      if (languages.isEmpty) {
        // Fallback to basic languages if backend fails to return any
        emit(LanguageLoaded(const [
          Language(id: '1', code: 'en', name: 'English'),
          Language(id: '2', code: 'sw', name: 'Swahili'),
          Language(id: '3', code: 'am', name: 'Amharic'),
          Language(id: '4', code: 'so', name: 'Somali'),
        ]));
      } else {
        emit(LanguageLoaded(languages));
      }
    } catch (e) {
      emit(LanguageError(e.toString()));
    }
  }
}
