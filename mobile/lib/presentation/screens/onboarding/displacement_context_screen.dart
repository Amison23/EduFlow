import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';

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

  final List<Map<String, dynamic>> _displacementOptions = [
    {
      'value': AppConstants.displacementConflict,
      'title': 'Conflict/Displacement',
      'description': 'I was displaced due to conflict or violence',
      'icon': Icons.warning_amber,
    },
    {
      'value': AppConstants.displacementClimate,
      'title': 'Climate Disaster',
      'description': 'I was displaced due to floods, drought, or climate change',
      'icon': Icons.cloud,
    },
    {
      'value': AppConstants.displacementOther,
      'title': 'Other',
      'description': 'Other reason for displacement',
      'icon': Icons.help_outline,
    },
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('About You'),
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
              'Why are you displaced?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._displacementOptions.map((option) => _buildOptionCard(option)),
            const SizedBox(height: 24),

            // Region
            Text(
              'Current Location',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRegion,
              decoration: const InputDecoration(
                hintText: 'Select your location',
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
              'Preferred Language',
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
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Continue'),
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

// Import the phone auth screen
import 'phone_auth_screen.dart';
