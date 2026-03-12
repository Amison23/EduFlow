import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';

/// Centralized logging service for Flutter
class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  final ApiClient _apiClient = ApiClient();
  String? _userId;

  /// Set the user ID for inclusion in logs
  void setUserId(String? userId) {
    _userId = userId;
  }

  /// Log an error to the server
  Future<void> logError({
    required String message,
    String? stackTrace,
    String level = 'error',
    Map<String, dynamic>? context,
  }) async {
    try {
      final data = {
        'level': level,
        'message': message,
        'stackTrace': stackTrace,
        'source': 'mobile',
        'userId': _userId,
        'context': {
          'platform': defaultTargetPlatform.toString(),
          'isWeb': kIsWeb,
          'timestamp': DateTime.now().toIso8601String(),
          ...?context,
        },
      };

      if (kDebugMode) {
        print('Reporting error to backend: $message');
      }

      await _apiClient.post(
        ApiConstants.logs,
        data: data,
      );
    } catch (e) {
      // Avoid infinite loops if logging itself fails
      if (kDebugMode) {
        print('Critical failure in LogService: $e');
      }
    }
  }

  /// Log a fatal crash
  Future<void> logFatal(Object error, StackTrace stack) async {
    await logError(
      message: error.toString(),
      stackTrace: stack.toString(),
      level: 'critical',
    );
  }
}
