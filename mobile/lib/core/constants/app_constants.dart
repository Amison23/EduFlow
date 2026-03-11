/// Application-wide constants for EduFlow
class AppConstants {
  AppConstants._();

  /// App name
  static const String appName = 'EduFlow';
  static const String appTagline = 'Lifeline Learning for Africa\'s Displaced';

  /// Supported languages
  static const String english = 'en';
  static const String swahili = 'sw';
  static const String amharic = 'am';

  /// Displacement types
  static const String displacementConflict = 'conflict';
  static const String displacementClimate = 'climate';
  static const String displacementOther = 'other';

  /// Subject areas
  static const String subjectMath = 'math';
  static const String subjectEnglish = 'english';
  static const String subjectSwahili = 'swahili';
  static const String subjectDigital = 'digital';

  /// Lesson levels
  static const int levelBeginner = 1;
  static const int levelIntermediate = 2;
  static const int levelAdvanced = 3;

  /// Sync settings
  static const int maxSyncBatchSize = 100;
  static const Duration syncRetryDelay = Duration(seconds: 30);
  static const Duration syncMaxDelay = Duration(minutes: 5);

  /// Quiz settings
  static const int questionsPerQuiz = 5;
  static const int quizTimeLimitMinutes = 10;
  static const double passingScore = 0.7;

  /// Storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyPhoneHash = 'phone_hash';
  static const String keyLearnerId = 'learner_id';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyDisplacementContext = 'displacement_context';
  static const String keyPreferredLanguage = 'preferred_language';
  static const String keyLastSyncTime = 'last_sync_time';

  /// SMS codes
  static const String smsStartCode = 'START';
  static const String smsHelpCode = 'HELP';
  static const String smsStopCode = 'STOP';
  static const String smsShortcode = '33528';

  /// Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}
