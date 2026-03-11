import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Screen for taking a quiz
class QuizScreen extends StatefulWidget {
  final String lessonId;
  final List<Map<String, dynamic>> questions;

  const QuizScreen({
    super.key,
    required this.lessonId,
    required this.questions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  List<int> _answers = [];

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No questions available')),
      );
    }

    if (_currentQuestionIndex >= widget.questions.length) {
      return _buildResultsScreen();
    }

    final question = widget.questions[_currentQuestionIndex];
    final options = question['options'] as List;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentQuestionIndex + 1}/${widget.questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.questions.length,
              backgroundColor: AppTheme.textHint.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            // Question
            Text(
              question['question'] ?? '',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Options
            ...List.generate(options.length, (index) {
              return _buildOption(index, options[index]);
            }),
            const Spacer(),
            // Next button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _answered ? _nextQuestion : null,
                child: Text(_answered 
                    ? (_currentQuestionIndex < widget.questions.length - 1 
                        ? 'Next Question' 
                        : 'See Results')
                    : 'Submit Answer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, String option) {
    final isSelected = _selectedAnswer == index;
    final isCorrect = widget.questions[_currentQuestionIndex]['correct_index'] == index;
    
    Color? backgroundColor;
    Color? borderColor;
    
    if (_answered) {
      if (isCorrect) {
        backgroundColor = AppTheme.secondaryColor.withValues(alpha: 0.2);
        borderColor = AppTheme.secondaryColor;
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppTheme.errorColor.withValues(alpha: 0.2);
        borderColor = AppTheme.errorColor;
      }
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryColor.withValues(alpha: 0.1);
      borderColor = AppTheme.primaryColor;
    }

    return GestureDetector(
      onTap: _answered ? null : () => setState(() => _selectedAnswer = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          border: Border.all(color: borderColor ?? AppTheme.textHint),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textHint.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(option)),
            if (_answered && isCorrect)
              const Icon(Icons.check_circle, color: AppTheme.secondaryColor),
          ],
        ),
      ),
    );
  }

  void _nextQuestion() {
    _answers.add(_selectedAnswer ?? -1);
    
    if (_selectedAnswer == widget.questions[_currentQuestionIndex]['correct_index']) {
      _score++;
    }

    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      setState(() {});
    }
  }

  Widget _buildResultsScreen() {
    final percentage = (_score / widget.questions.length * 100).round();
    final passed = percentage >= 70;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.celebration : Icons.refresh,
                size: 80,
                color: passed ? AppTheme.secondaryColor : AppTheme.errorColor,
              ),
              const SizedBox(height: 24),
              Text(
                passed ? 'Congratulations!' : 'Keep Practicing!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You scored $_score out of ${widget.questions.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: passed ? AppTheme.secondaryColor : AppTheme.errorColor,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Lessons'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
