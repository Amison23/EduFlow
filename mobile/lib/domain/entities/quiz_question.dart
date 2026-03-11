/// Quiz Question entity
class QuizQuestion {
  final String id;
  final String lessonId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String? topic;

  const QuizQuestion({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.topic,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correct_index'] as int,
      explanation: json['explanation'] as String?,
      topic: json['topic'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'question': question,
      'options': options,
      'correct_index': correctIndex,
      'explanation': explanation,
      'topic': topic,
    };
  }

  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctIndex;
  }

  String get correctAnswer => options[correctIndex];
}
