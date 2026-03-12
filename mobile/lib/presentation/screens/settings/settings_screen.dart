import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eduflow/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/locale/locale_cubit.dart';
import '../../bloc/theme/theme_cubit.dart';
import '../../bloc/language/language_cubit.dart';
import '../../../domain/entities/language.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _pendingLanguageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: [
          if (_pendingLanguageCode != null)
            TextButton(
              onPressed: () {
                context.read<LocaleCubit>().setLocale(_pendingLanguageCode!);
                setState(() {
                  _pendingLanguageCode = null;
                });
              },
              child: const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, l10n.appearance),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return ListTile(
                leading: Icon(
                  themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                  color: AppTheme.primaryColor,
                ),
                title: Text(l10n.darkMode),
                trailing: Switch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                ),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.language),
          BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, langState) {
              return BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) {
                  final activeCode = _pendingLanguageCode ?? locale.languageCode;
                  
                  if (langState is LanguageLoading) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  
                  if (langState is LanguageLoaded) {
                    return Column(
                      children: langState.languages.map((lang) {
                        return _buildLanguageOption(context, lang, activeCode == lang.code);
                      }).toList(),
                    );
                  }
                  
                  // Fallback if error or initial
                  return Column(
                    children: [
                      _buildBasicLanguageOption(context, 'en', 'English', '🇺🇸', activeCode == 'en'),
                      _buildBasicLanguageOption(context, 'sw', 'Kiswahili', '🇰🇪', activeCode == 'sw'),
                      _buildBasicLanguageOption(context, 'am', 'Amharic', '🇪🇹', activeCode == 'am'),
                      _buildBasicLanguageOption(context, 'so', 'Af-Soomaali', '🇸🇴', activeCode == 'so'),
                    ],
                  );
                },
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.about),
          const ListTile(
            leading: Icon(Icons.info_outline, color: AppTheme.primaryColor),
            title: Text('EduFlow v1.0.0'),
            subtitle: Text('Built for Africa Forward Hackathon'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, Language language, bool isSelected) {
    return ListTile(
      leading: Text(language.flag, style: const TextStyle(fontSize: 24)),
      title: Text(language.name),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.secondaryColor) : null,
      onTap: () {
        setState(() {
          _pendingLanguageCode = language.code;
        });
      },
    );
  }

  Widget _buildBasicLanguageOption(BuildContext context, String code, String name, String flag, bool isSelected) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.secondaryColor) : null,
      onTap: () {
        setState(() {
          _pendingLanguageCode = code;
        });
      },
    );
  }
}
