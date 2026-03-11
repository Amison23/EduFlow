import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eduflow/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'phone_auth_screen.dart';

/// Screen for selecting displacement context
class DisplacementContextScreen extends StatefulWidget {
  const DisplacementContextScreen({super.key});

  @override
  State<DisplacementContextScreen> createState() => _DisplacementContextScreenState();
}

class _DisplacementContextScreenState extends State<DisplacementContextScreen> {
  String? _selectedContext;
  String? _selectedRegion;
  String? _selectedLanguage;

  List<Map<String, dynamic>> _getDisplacementOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'value': AppConstants.displacementConflict,
        'title': l10n.conflictDisplacement,
        'description': l10n.conflictDescription,
        'icon': Icons.warning_amber,
      },
      {
        'value': AppConstants.displacementClimate,
        'title': l10n.climateDisaster,
        'description': l10n.climateDescription,
        'icon': Icons.cloud,
      },
      {
        'value': AppConstants.displacementOther,
        'title': l10n.otherReason,
        'description': l10n.otherDescription,
        'icon': Icons.help_outline,
      },
    ];
  }

  final List<String> _regions = [
    'Dadaab, Kenya',
    'Kakuma, Kenya',
    'Nakuru, Kenya',
    'Addis Ababa, Ethiopia',
    'Kampala, Uganda',
    'Dar es Salaam, Tanzania',
    'Other',
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'sw', 'name': 'Swahili'},
    {'code': 'am', 'name': 'Amharic'},
    {'code': 'so', 'name': 'Somali'},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displacementOptions = _getDisplacementOptions(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutYou),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displacement context
            Text(
              l10n.whyAreYouDisplaced,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...displacementOptions.map((option) => _buildOptionCard(option)),
            const SizedBox(height: 24),

            // Region
            Text(
              l10n.currentLocation,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedRegion,
              decoration: InputDecoration(
                hintText: l10n.selectYourLocation,
              ),
              items: _regions.map((region) => DropdownMenuItem(
                value: region,
                child: Text(region),
              )).toList(),
              onChanged: (value) => setState(() => _selectedRegion = value),
            ),
            const SizedBox(height: 24),

            // Language
            Text(
              l10n.preferredLanguage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _languages.map((lang) => ChoiceChip(
                label: Text(lang['name']!),
                selected: _selectedLanguage == lang['code'],
                onSelected: (selected) {
                  setState(() => _selectedLanguage = selected ? lang['code'] : null);
                },
              )).toList(),
            ),
            const SizedBox(height: 32),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedContext != null ? _continueToPhoneAuth : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(l10n.continueButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(Map<String, dynamic> option) {
    final isSelected = _selectedContext == option['value'];
    return GestureDetector(
      onTap: () => setState(() => _selectedContext = option['value']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textHint,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              option['icon'],
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['title'],
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    option['description'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  void _continueToPhoneAuth() {
    // Save to auth bloc
    context.read<AuthBloc>().add(UpdateProfile({
      'displacement': _selectedContext,
      'region': _selectedRegion,
      'language': _selectedLanguage ?? 'en',
    }));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PhoneAuthScreen(),
      ),
    );
  }
}
