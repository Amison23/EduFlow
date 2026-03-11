import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/lesson/lesson_bloc.dart';

/// Screen showing list of lesson packs
class PackListScreen extends StatelessWidget {
  const PackListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Packs'),
      ),
      body: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is LessonLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is LessonPacksLoaded) {
            if (state.packs.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildPackList(context, state.packs);
          }
          
          if (state is LessonError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final languageCode = Localizations.localeOf(context).languageCode;
                      context.read<LessonBloc>().add(LoadLessonPacks(language: languageCode));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          Text(
            'No lessons available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new content',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackList(BuildContext context, List<Map<String, dynamic>> packs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: packs.length,
      itemBuilder: (context, index) {
        final pack = packs[index];
        return _PackCard(pack: pack);
      },
    );
  }
}

class _PackCard extends StatelessWidget {
  final Map<String, dynamic> pack;

  const _PackCard({required this.pack});

  @override
  Widget build(BuildContext context) {
    final subject = pack['subject'] as String? ?? '';
    final level = pack['level'] as int? ?? 1;
    final sizeMb = pack['size_mb'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.read<LessonBloc>().add(LoadLessonsForPack(pack['id']));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _LessonsForPackScreen(packId: pack['id'], packTitle: pack['subject']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.getSubjectColor(subject).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppTheme.getSubjectIcon(subject),
                  color: AppTheme.getSubjectColor(subject),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${subject[0].toUpperCase()}${subject.substring(1)} - Level $level',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sizeMb != null ? '${sizeMb.toStringAsFixed(1)} MB' : 'Multiple lessons',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonsForPackScreen extends StatelessWidget {
  final String packId;
  final String packTitle;

  const _LessonsForPackScreen({required this.packId, required this.packTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$packTitle Lessons'),
      ),
      body: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is LessonLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is LessonsLoaded && state.packId == packId) {
            if (state.lessons.isEmpty) {
              return const Center(child: Text('No lessons in this pack'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.lessons.length,
              itemBuilder: (context, index) {
                final lesson = state.lessons[index];
                return _LessonCard(lesson: lesson);
              },
            );
          }
          
          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Text('${lesson['sequence']}'),
        ),
        title: Text(lesson['title'] ?? 'Lesson'),
        subtitle: lesson['duration_mins'] != null 
            ? Text('${lesson['duration_mins']} min')
            : null,
        trailing: const Icon(Icons.play_circle_outline),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _LessonDetailScreen(lesson: lesson),
            ),
          );
        },
      ),
    );
  }
}

class _LessonDetailScreen extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const _LessonDetailScreen({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson['title'] ?? 'Lesson'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson content
            Text(
              lesson['content'] ?? 'No content available',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            // Start Quiz button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<LessonBloc>().add(LoadQuizQuestions(lesson['id']));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _QuizScreen(lessonId: lesson['id']),
                    ),
                  );
                },
                icon: const Icon(Icons.quiz),
                label: const Text('Take Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizScreen extends StatelessWidget {
  final String lessonId;

  const _QuizScreen({required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is LessonLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is QuizLoaded) {
            if (state.questions.isEmpty) {
              return const Center(child: Text('No quiz questions available'));
            }
            return const Center(child: Text('Quiz in progress...'));
          }
          
          return const Center(child: Text('Loading quiz...'));
        },
      ),
    );
  }
}
