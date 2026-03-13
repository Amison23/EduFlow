import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Instructions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeroSection(context),
          const SizedBox(height: 24),
          _buildInstructionTile(
            context,
            icon: Icons.dashboard,
            title: 'Getting Started',
            content: 'The dashboard is your central hub. Here you can see your current points, '
                'lesson progress, and quickly jump back into your last learning session. '
                'Use the navigation bar at the bottom to switch between Home, Lessons, Community, and Profile.',
          ),
          _buildInstructionTile(
            context,
            icon: Icons.school,
            title: 'Lessons & Quizzes',
            content: '1. Navigate to the "Lessons" tab to see available subject packs (e.g., Math, English).\n'
                '2. Tap a pack to see individual lessons.\n'
                '3. Each lesson contains a reading section and an optional audio narration.\n'
                '4. After finishing a lesson, take the quiz to earn points and test your knowledge!',
          ),
          _buildInstructionTile(
            context,
            icon: Icons.group,
            title: 'Community & Study Groups',
            content: 'Want to learn with others? Visit the "Community" tab.\n'
                '- Join existing study groups based on your interests.\n'
                '- Create your own group to invite friends.\n'
                '- Participate in discussions and see how other learners are progressing.',
          ),
          _buildInstructionTile(
            context,
            icon: Icons.sms,
            title: 'SMS Learning (Offline Mode)',
            content: 'EduFlow works even when you don\'t have a data connection through our SMS gateway.\n\n'
                '**How to Use:**\n'
                '- When offline, the app will automatically prompt you to sync via SMS if critical updates are needed.\n'
                '- You can manually request a lesson update by clicking "Sync via SMS" in your profile.\n\n'
                '**Testing the SMS Function:**\n'
                '- To test, toggle your Wi-Fi/Mobile Data off and attempt to submit a quiz.\n'
                '- The app will queue the submission in the "Outbox" and offer to send a lightweight SMS update to our server (Standard rates may apply).',
          ),
          _buildInstructionTile(
            context,
            icon: Icons.sync,
            title: 'Offline Sync & Outbox',
            content: 'Everything you do while offline is saved securely on your device.\n'
                '- **Outbox**: Check your profile to see pending sync requests.\n'
                '- **Auto-Sync**: When you regain internet connection, the app will automatically upload your progress to the server in the background.',
          ),
          const SizedBox(height: 40),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.help_center_outlined, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'How to use EduFlow',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Master the app and learn anywhere, anytime.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: TextStyle(
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Still need help?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Contact us at support@eduflow.org',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
