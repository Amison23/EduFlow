/// Service for adaptive quizzing using topic-based mastery weights.
/// This implementation simulates a TFLite model by tracking performance 
/// trends across different learning subjects and topics.
class TfliteQuizService {
  /// Topic weights: 1.0 is default, >1.0 needs reinforcement, <1.0 demonstrates mastery
  final Map<String, double> _topicWeights = {};
  
  /// Streak tracking for topics
  final Map<String, int> _topicStreaks = {};

  /// Initialize the service
  Future<void> init() async {
    // Simulated model loading
  }

  /// Initialize mastery from server-side events
  void initializeFromEvents(List<dynamic> events) {
    _topicWeights.clear();
    _topicStreaks.clear();

    // Group events by topic and calculate mastery
    // We assume the backend returns events with 'lesson_id' or 'subject' context
    for (var event in events) {
      final topic = event['lessons']?['lesson_packs']?['subject'] ?? 'general';
      final isCorrect = event['event_type'] == 'quiz_completed' && (event['score'] ?? 0) >= 0.7;
      
      updateTopicWeight(topic, isCorrect);
    }
  }

  /// Get the current mastery status for all topics
  Map<String, double> getTopicWeights() {
    return Map.from(_topicWeights);
  }

  /// Update topic mastery based on quiz result
  void updateTopicWeight(String topic, bool correct) {
    _topicWeights[topic] ??= 1.0;
    _topicStreaks[topic] ??= 0;

    if (correct) {
      _topicStreaks[topic] = (_topicStreaks[topic]! + 1);
      // Accelerate mastery if on a silver/gold streak
      double adjustment = _topicStreaks[topic]! > 3 ? 0.85 : 0.95;
      _topicWeights[topic] = (_topicWeights[topic]! * adjustment).clamp(0.1, 2.0);
    } else {
      _topicStreaks[topic] = 0;
      // Heavier weight increase for failures to ensure reinforcement
      _topicWeights[topic] = (_topicWeights[topic]! * 1.25).clamp(0.1, 2.0);
    }
  }

  /// Get recommended subjects/topics for practice
  List<String> getRecommendedTopics({int count = 3}) {
    if (_topicWeights.isEmpty) return [];
    
    final sortedTopics = _topicWeights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTopics.take(count).map((e) => e.key).toList();
  }

  /// Calculate mastery percentage (0.0 to 1.0)
  double getMasteryScore() {
    if (_topicWeights.isEmpty) return 0.0;
    
    final totalWeight = _topicWeights.values.reduce((a, b) => a + b);
    final avgWeight = totalWeight / _topicWeights.length;
    
    // Transform weights into a mastery percentage
    // 0.1 weight = ~95% mastery, 2.0 weight = ~0% mastery
    return ((2.0 - avgWeight) / 1.9).clamp(0.0, 1.0);
  }

  /// Get a personalized supportive message based on mastery and streaks
  String getAdaptiveInsight(String topic, bool lastAnswerCorrect) {
    _topicWeights[topic] ??= 1.0;
    _topicStreaks[topic] ??= 0;
    
    final weight = _topicWeights[topic]!;
    final streak = _topicStreaks[topic]!;

    if (lastAnswerCorrect) {
      if (streak >= 3) {
        return "You're on fire! $streak in a row. You've clearly mastered this part.";
      }
      if (weight < 0.6) {
        return "Excellent! Your understanding of $topic is getting very strong.";
      }
      return "Correct! You're making steady progress.";
    } else {
      if (weight > 1.5) {
        return "Don't worry, $topic can be tricky. Let's focus more on this area.";
      }
      return "Close! Every mistake is a step toward learning. You'll get it next time.";
    }
  }

  /// Get the reason why a topic is recommended
  String getRecommendationReason(String topic) {
    final weight = _topicWeights[topic] ?? 1.0;
    final streak = _topicStreaks[topic] ?? 0;

    if (weight > 1.3) {
      return "Reinforce this area";
    }
    if (streak > 2) {
      return "Keep your streak going";
    }
    if (weight < 0.5) {
      return "Mastery maintenance";
    }
    return "Next logical step";
  }

  /// Simulate AI-driven peer compatibility insight
  String getPeerCompatibilityInsight(Map<String, dynamic> peerData) {
    // In a real app, this would compare peer mastery levels with current user
    final randomInsights = [
      "Fast Learner Like You",
      "Expert in this Subject",
      "Active Today",
      "Goal Oriented",
      "Morning Learner",
    ];
    
    // Deterministic based on peer ID for demo stability
    final id = peerData['id']?.toString() ?? '0';
    final index = id.hashCode % randomInsights.length;
    return randomInsights[index];
  }

  /// Reset all learned weights
  void resetWeights() {
    _topicWeights.clear();
    _topicStreaks.clear();
  }

  /// Clean up
  void dispose() {}
}
