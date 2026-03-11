import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Card widget for displaying a lesson
class LessonCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String subject;
  final int? durationMins;
  final bool isCompleted;
  final bool isDownloaded;
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.subject,
    this.durationMins,
    this.isCompleted = false,
    this.isDownloaded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Subject icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.getSubjectColor(subject).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : AppTheme.getSubjectIcon(subject),
                  color: isCompleted 
                      ? AppTheme.secondaryColor 
                      : AppTheme.getSubjectColor(subject),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (durationMins != null) ...[
                          Icon(Icons.schedule, size: 14, color: AppTheme.textHint),
                          const SizedBox(width: 4),
                          Text(
                            '$durationMins min',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textHint,
                            ),
                          ),
                        ],
                        if (isDownloaded) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.download_done, size: 14, color: AppTheme.secondaryColor),
                          const SizedBox(width: 4),
                          Text(
                            'Downloaded',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              const Icon(Icons.chevron_right, color: AppTheme.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
