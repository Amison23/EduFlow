import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';

/// Screen for viewing a lesson
class LessonScreen extends StatefulWidget {
  final String lessonId;
  final String title;
  final String content;

  const LessonScreen({
    super.key,
    required this.lessonId,
    required this.title,
    required this.content,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.volume_up : Icons.volume_off),
            onPressed: _toggleAudio,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Audio player card
            if (_isPlaying) _buildAudioPlayer(),
            const SizedBox(height: 16),
            // Lesson content
            Text(
              widget.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.audiotrack, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Playing narration...'),
          ),
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
    if (_isPlaying) {
      await _audioService.stop();
      setState(() => _isPlaying = false);
    } else {
      // In real implementation, would play actual audio
      setState(() => _isPlaying = true);
    }
  }
}
