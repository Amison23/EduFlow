// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'EduFlow';

  @override
  String get appTagline => 'Lifeline Learning for All Learners';

  @override
  String get aboutYou => 'About You';

  @override
  String get whyAreYouDisplaced => 'Tell us about your context';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get selectYourLocation => 'Select your location';

  @override
  String get preferredLanguage => 'Preferred Language';

  @override
  String get continueButton => 'Continue';

  @override
  String get conflictDisplacement => 'Conflict/Displacement';

  @override
  String get conflictDescription =>
      'I was displaced due to conflict or violence';

  @override
  String get climateDisaster => 'Climate Disaster';

  @override
  String get climateDescription =>
      'I was displaced due to floods, drought, or climate change';

  @override
  String get remoteRegion => 'Remote Region';

  @override
  String get remoteRegionDescription =>
      'I live in a remote area with limited access to schools';

  @override
  String get otherReason => 'Other';

  @override
  String get otherDescription => 'Other situational context';

  @override
  String get worksOffline => 'Works Offline';

  @override
  String get worksOfflineDesc => 'Download lessons and learn without internet';

  @override
  String get smsLearning => 'SMS Learning';

  @override
  String smsLearningDesc(Object shortcode) {
    return 'No internet? Use our SMS service by sending keywords to $shortcode.';
  }

  @override
  String get studyGroups => 'Study Groups';

  @override
  String get studyGroupsDesc => 'Connect with other learners';

  @override
  String get getStarted => 'Get Started';

  @override
  String get phoneLogin => 'Phone Login';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get verificationCodeDesc => 'We\'ll send you a verification code';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get phoneNumberHint => '+254712345678';

  @override
  String get sendCode => 'Send Code';

  @override
  String get enterCode => 'Enter the code';

  @override
  String sentCodeTo(String phoneNumber) {
    return 'We sent a 6-digit code to $phoneNumber';
  }

  @override
  String get verificationCodeLabel => 'Verification Code';

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get changePhoneNumber => 'Change Phone Number';

  @override
  String get pleaseEnterPhone => 'Please enter a phone number';

  @override
  String get pleaseEnterOtp => 'Please enter the 6-digit code';

  @override
  String get helpAndGuide => 'Help & Guide';

  @override
  String get howToUseApp => 'How to use the app';

  @override
  String get gettingStartedTitle => 'Getting Started';

  @override
  String get gettingStartedDesc =>
      'Learn how to navigate and start your learning journey.';

  @override
  String get offlineLearningTitle => 'Offline Learning';

  @override
  String get offlineLearningDesc =>
      'Save data by downloading lessons to use them anywhere, anytime.';

  @override
  String get smsLearningTitle => 'SMS Lessons (No Internet)';

  @override
  String get communityTitle => 'Study Groups';

  @override
  String get communityDesc =>
      'Join or create a group to learn together with your friends.';

  @override
  String get gotIt => 'Got it!';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get about => 'About';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get continueLearning => 'Continue Learning';

  @override
  String get joinStudyGroup => 'Join Study Group';

  @override
  String get subjects => 'Subjects';

  @override
  String get goodMorning => 'Good Morning!';

  @override
  String get readyToLearn => 'Ready to learn today?';

  @override
  String get lessonPacks => 'Lesson Packs';

  @override
  String get retry => 'Retry';

  @override
  String get noLessonsAvailable => 'No lessons available';

  @override
  String get checkBackLater => 'Check back later for new content';

  @override
  String get multipleLessons => 'Multiple lessons';

  @override
  String get lessons => 'Lessons';

  @override
  String get noLessonsInPack => 'No lessons in this pack';

  @override
  String get loading => 'Loading...';

  @override
  String get min => 'min';

  @override
  String get takeQuiz => 'Take Quiz';

  @override
  String get playingAudio => 'Playing audio narration...';

  @override
  String get smartRecommendations => 'Smart Recommendations';

  @override
  String get recommendedForYou => 'Recommended for you based on progress';

  @override
  String get aiRecommended => 'AI Recommended';

  @override
  String get learningProgress => 'Learning Progress';

  @override
  String get codeSent => 'Verification code sent';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';
}
