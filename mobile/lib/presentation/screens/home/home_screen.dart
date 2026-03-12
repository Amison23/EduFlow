import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/lesson/lesson_bloc.dart';
import '../../bloc/sync/sync_cubit.dart';
import '../../widgets/sync_indicator.dart';
import '../lessons/pack_list_screen.dart';
import '../community/study_group_screen.dart';
import '../../bloc/progress/progress_bloc.dart';
import '../settings/settings_screen.dart';
import '../../../services/tflite_quiz_service.dart';
import 'package:eduflow/l10n/app_localizations.dart';

/// Home screen - main dashboard after login
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load lesson packs in the current language
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final languageCode = Localizations.localeOf(context).languageCode;
      context.read<LessonBloc>().add(LoadLessonPacks(language: languageCode));
    });
    // Initialize sync
    context.read<SyncCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduFlow'),
        actions: [
          const SyncIndicator(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          PackListScreen(),
          StudyGroupScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(Logout());
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}



/// Dashboard tab content
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressBloc, ProgressState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              _buildWelcomeCard(context, state),
              const SizedBox(height: 24),
              
              // Quick actions
              Text(
                AppLocalizations.of(context)?.quickActions ?? 'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      context,
                      Icons.play_circle_fill,
                      AppLocalizations.of(context)?.continueLearning ?? 'Continue Learning',
                      AppTheme.primaryColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PackListScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      context,
                      Icons.people,
                      AppLocalizations.of(context)?.joinStudyGroup ?? 'Join Study Group',
                      AppTheme.secondaryColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StudyGroupScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Subjects
              Text(
                AppLocalizations.of(context)?.subjects ?? 'Subjects',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSubjectCard(context, 'Math', Icons.calculate, AppTheme.mathColor),
                    _buildSubjectCard(context, 'English', Icons.menu_book, AppTheme.englishColor),
                    _buildSubjectCard(context, 'Swahili', Icons.translate, AppTheme.swahiliColor),
                    _buildSubjectCard(context, 'Digital', Icons.computer, AppTheme.digitalColor),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Smart Recommendations
              _buildSmartRecommendations(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSmartRecommendations(BuildContext context) {
    final quizService = context.read<TfliteQuizService>();
    final l10n = AppLocalizations.of(context)!;
    final recommendedTopics = quizService.getRecommendedTopics();
    
    if (recommendedTopics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.smartRecommendations,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 14, color: AppTheme.secondaryColor),
                  const SizedBox(width: 4),
                  Text(
                    l10n.aiRecommended,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.recommendedForYou,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendedTopics.length,
            itemBuilder: (context, index) {
              final topic = recommendedTopics[index];
              final reason = quizService.getRecommendationReason(topic);
              return _buildRecommendationCard(context, topic, reason);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(BuildContext context, String topic, String reason) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                _getIconForSubject(topic),
                size: 24,
                color: _getColorForSubject(topic),
              ),
              const Icon(
                Icons.auto_awesome,
                size: 14,
                color: AppTheme.secondaryColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            topic,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              reason,
              style: const TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppTheme.secondaryColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PackListScreen()),
                );
              },
              child: const Text('Practice', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForSubject(String subject) {
    switch (subject.toLowerCase()) {
      case 'math': return Icons.calculate;
      case 'english': return Icons.menu_book;
      case 'swahili': return Icons.translate;
      case 'digital': return Icons.computer;
      default: return Icons.book;
    }
  }

  Color _getColorForSubject(String subject) {
    switch (subject.toLowerCase()) {
      case 'math': return AppTheme.mathColor;
      case 'english': return AppTheme.englishColor;
      case 'swahili': return AppTheme.swahiliColor;
      case 'digital': return AppTheme.digitalColor;
      default: return AppTheme.primaryColor;
    }
  }

  Widget _buildWelcomeCard(BuildContext context, ProgressState state) {
    int streak = 0;
    int points = 0;

    if (state is ProgressLoaded) {
      streak = state.streak;
      points = state.progress['total_points'] ?? 0;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Row(
                children: [
                  const Icon(Icons.wb_sunny, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)?.goodMorning ?? 'Good Morning!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)?.readyToLearn ?? 'Ready to learn today?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip('🔥 $streak day streak'),
              const SizedBox(width: 8),
              _buildStatChip('⭐ $points points'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
