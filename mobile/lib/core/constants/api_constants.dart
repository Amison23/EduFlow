import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API constants for EduFlow backend
class ApiConstants {
  ApiConstants._();

  /// Base URL for the API
  /// In production, this would be the Render deployed URL
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5000/api/v1';

  /// API endpoints
  static const String auth = '/auth';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  
  static const String lessons = '/lessons';
  static const String lessonPacks = '/lessons/packs';
  static const String downloadPack = '/lessons/packs/download';
  
  static const String progress = '/progress';
  static const String syncProgress = '/progress/sync';
  
  static const String community = '/community';
  static const String studyGroups = '/community/groups';
  static const String findPeers = '/community/peers';

  /// SMS endpoints
  static const String smsInbound = '/sms/inbound';
  static const String smsOutbound = '/sms/outbound';

  /// Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Rate limiting
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 5);
}
