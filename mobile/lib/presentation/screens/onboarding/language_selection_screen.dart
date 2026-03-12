import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/locale/locale_cubit.dart';
import '../../bloc/language/language_cubit.dart';
import '../../../domain/entities/language.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguageCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor, Color(0xFF1565C0)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.translate, size: 48, color: Colors.white),
                const SizedBox(height: 24),
                Text(
                  'Choose your language',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Select your preferred language to continue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 48),
                Expanded(
                  child: BlocBuilder<LanguageCubit, LanguageState>(
                    builder: (context, state) {
                      if (state is LanguageLoading) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      
                      if (state is LanguageLoaded) {
                        return ListView.builder(
                          itemCount: state.languages.length,
                          itemBuilder: (context, index) {
                            final lang = state.languages[index];
                            return _buildLanguageItem(context, lang);
                          },
                        );
                      }
                      
                      if (state is LanguageError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.white, size: 48),
                              const SizedBox(height: 16),
                              Text(state.message, style: const TextStyle(color: Colors.white)),
                              TextButton(
                                onPressed: () => context.read<LanguageCubit>().fetchLanguages(),
                                child: const Text('Retry', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return const SizedBox();
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedLanguageCode != null ? _onProceed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      disabledBackgroundColor: Colors.white.withValues(alpha: 0.3),
                      disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Proceed',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onProceed() {
    if (_selectedLanguageCode != null) {
      // Update app locale
      context.read<LocaleCubit>().setLocale(_selectedLanguageCode!);
      // Notify auth bloc that language is selected
      context.read<AuthBloc>().add(const SetAppLanguage());
    }
  }

  Widget _buildLanguageItem(BuildContext context, Language language) {
    final isSelected = _selectedLanguageCode == language.code;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguageCode = language.code;
        });
        // Optional: Pre-emptively update locale so user can see the UI translate immediately
        // but don't navigate yet.
        context.read<LocaleCubit>().setLocale(language.code);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(language.flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              language.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}
