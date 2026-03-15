import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:eduflow/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import '../../bloc/lesson/lesson_bloc.dart';
import 'quiz_screen.dart';

/// Screen showing list of lesson packs
class PackListScreen extends StatelessWidget {
  const PackListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.lessonPacks ?? 'Lesson Packs'),
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

          if (state is LessonsLoaded) {
             if (state.packs.isEmpty) {
              // Try to reload if we somehow lost packs
              final languageCode = Localizations.localeOf(context).languageCode;
              context.read<LessonBloc>().add(LoadLessonPacks(language: languageCode));
              return const Center(child: CircularProgressIndicator());
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
                        child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
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
          const Icon(Icons.library_books, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)?.noLessonsAvailable ?? 'No lessons available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.checkBackLater ?? 'Check back later for new content',
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
                      sizeMb != null 
                          ? '${sizeMb.toStringAsFixed(1)} MB' 
                          : AppLocalizations.of(context)?.multipleLessons ?? 'Multiple lessons',
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
        title: Text('$packTitle ${AppLocalizations.of(context)?.lessons ?? 'Lessons'}'),
      ),
      body: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is LessonLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is LessonsLoaded && state.packId == packId) {
            if (state.lessons.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)?.noLessonsInPack ?? 'No lessons in this pack'));
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
          
          return Center(child: Text(AppLocalizations.of(context)?.loading ?? 'Loading...'));
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
            ? Text('${lesson['duration_mins']} ${AppLocalizations.of(context)?.min ?? 'min'}')
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

class _LessonDetailScreen extends StatefulWidget {
  final Map<String, dynamic> lesson;

  const _LessonDetailScreen({required this.lesson});

  @override
  State<_LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<_LessonDetailScreen> {
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String content = widget.lesson['content'] ?? 'No content available';
    final String? audioUrl = widget.lesson['audio_url'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson['title'] ?? 'Lesson'),
        actions: [
          if (audioUrl != null)
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
              onPressed: _toggleAudio,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isPlaying) _buildAudioPlayer(),
            const SizedBox(height: 16),
            MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(
                        lessonId: widget.lesson['id'],
                        subject: widget.lesson['subject'] ?? 'general',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.quiz),
                label: Text(AppLocalizations.of(context)?.takeQuiz ?? 'Take Quiz'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.audiotrack, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          const Expanded(child: Text('Playing audio narration...')), // To be localized if needed
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () {
              _audioService.stop();
              setState(() => _isPlaying = false);
            },
          ),
        ],
      ),
    );
  }

  void _toggleAudio() async {
    final String? audioUrl = widget.lesson['audio_url'];
    if (audioUrl == null) return;

    if (_isPlaying) {
      await _audioService.stop();
      setState(() => _isPlaying = false);
    } else {
      await _audioService.playFromUrl(audioUrl);
      setState(() => _isPlaying = true);
    }
  }
}

// Note: _QuizScreen internal class removed in favor of the external QuizScreen in quiz_screen.dart
