import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eduflow/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/locale/locale_cubit.dart';
import '../../bloc/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
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
          BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return Column(
                children: [
                  _buildLanguageOption(context, 'en', 'English', '🇺🇸', locale.languageCode == 'en'),
                  _buildLanguageOption(context, 'sw', 'Kiswahili', '🇰🇪', locale.languageCode == 'sw'),
                  _buildLanguageOption(context, 'am', 'Amharic', '🇪🇹', locale.languageCode == 'am'),
                ],
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

  Widget _buildLanguageOption(BuildContext context, String code, String name, String flag, bool isSelected) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.secondaryColor) : null,
      onTap: () {
        context.read<LocaleCubit>().setLocale(code);
      },
    );
  }
}
