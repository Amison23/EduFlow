import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/tflite_quiz_service.dart';
import '../../bloc/lesson/lesson_bloc.dart';

/// Screen for taking a quiz with adaptive feedback
class QuizScreen extends StatefulWidget {
  final String lessonId;
  final String subject;

  const QuizScreen({
    super.key,
    required this.lessonId,
    required this.subject,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final TfliteQuizService _quizService;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _quizCompleted = false;
  String? _currentInsight;

  @override
  void initState() {
    super.initState();
    _quizService = context.read<TfliteQuizService>();
    // Trigger loading questions if not already loaded
    context.read<LessonBloc>().add(LoadQuizQuestions(widget.lessonId));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonBloc, LessonState>(
      builder: (context, state) {
        if (state is LessonLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is LessonError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Quiz Error')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<LessonBloc>().add(LoadQuizQuestions(widget.lessonId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is QuizLoaded) {
          if (state.questions.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: const Text('Quiz')),
              body: const Center(child: Text('No questions available for this lesson.')),
            );
          }

          if (_quizCompleted) {
            return _buildResultsScreen(state.questions);
          }

          final question = state.questions[_currentQuestionIndex];
          final options = question['options'] as List;

          return Scaffold(
            appBar: AppBar(
              title: Text('Question ${_currentQuestionIndex + 1}/${state.questions.length}'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / state.questions.length,
                    backgroundColor: AppTheme.textHint.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    question['question'] ?? '',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(options.length, (index) {
                    return _buildOption(state.questions, index, options[index]);
                  }),
                  if (_answered && _currentInsight != null) ...[
                    const SizedBox(height: 24),
                    _buildInsightCard(),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedAnswer != null ? () {
                        if (!_answered) {
                          _handleSubmit(state.questions);
                        } else {
                          _nextQuestion(state.questions);
                        }
                      } : null,
                      child: Text(_answered 
                          ? (_currentQuestionIndex < state.questions.length - 1 
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

        return const Scaffold(
          body: Center(child: Text('Initializing quiz...')),
        );
      },
    );
  }

  Widget _buildOption(List<Map<String, dynamic>> questions, int index, String option) {
    final isSelected = _selectedAnswer == index;
    final isCorrect = questions[_currentQuestionIndex]['correct_index'] == index;
    
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          border: Border.all(
            color: borderColor ?? AppTheme.textHint,
            width: (_answered && (isCorrect || (isSelected && !isCorrect))) ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isSelected && !_answered)
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
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
                  String.fromCharCode(64 + (index + 1)), // A, B, C, D
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

  void _handleSubmit(List<Map<String, dynamic>> questions) {
    setState(() {
      _answered = true;
      final bool correct = _selectedAnswer == questions[_currentQuestionIndex]['correct_index'];
      if (correct) _score++;
      
      // Update mastery weight in real-time
      _quizService.updateTopicWeight(widget.subject, correct);
      
      // Get AI insight
      _currentInsight = _quizService.getAdaptiveInsight(widget.subject, correct);
    });
  }

  void _nextQuestion(List<Map<String, dynamic>> questions) {
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _answered = false;
        _currentInsight = null;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppTheme.secondaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentInsight!,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen(List<Map<String, dynamic>> questions) {
    final percentage = (_score / questions.length * 100).round();
    final mastery = _quizService.getMasteryScore();
    final passed = percentage >= 70;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results'), automaticallyImplyLeading: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.emoji_events : Icons.school,
                size: 80,
                color: passed ? AppTheme.secondaryColor : AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                passed ? 'Great Job!' : 'Keep Learning!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildResultStat('Score', '$_score / ${questions.length}'),
              _buildResultStat('Mastery', '${(mastery * 100).toStringAsFixed(0)}%'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Finish Lesson'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}
