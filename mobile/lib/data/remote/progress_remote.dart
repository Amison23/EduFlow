import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';

/// Remote data source for progress tracking
class ProgressRemote {
  final ApiClient _apiClient = ApiClient();

  /// Sync progress events to server
  Future<Map<String, dynamic>> syncProgress({
    required String learnerId,
    required List<Map<String, dynamic>> events,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.syncProgress,
        data: {
          'learner_id': learnerId,
          'events': events,
        },
      );
      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to sync progress', originalError: e);
    }
  }

  /// Get learner progress from server
  Future<List<dynamic>> getProgress(String learnerId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.progress}/$learnerId',
      );
      return response.data as List<dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch progress', originalError: e);
    }
  }

  /// Get progress for a specific subject
  Future<Map<String, dynamic>> getSubjectProgress(
    String learnerId,
    String subject,
  ) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.progress}/$learnerId/$subject',
      );
      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch subject progress', originalError: e);
    }
  }

  /// Get learner streak
  Future<int> getStreak(String learnerId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.progress}/$learnerId/streak',
      );
      final data = response.data as Map<String, dynamic>;
      return data['streak'] as int? ?? 0;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch streak', originalError: e);
    }
  }

  /// Submit quiz answers
  Future<Map<String, dynamic>> submitQuizAnswers({
    required String learnerId,
    required String lessonId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.progress}/quiz/submit',
        data: {
          'learner_id': learnerId,
          'lesson_id': lessonId,
          'answers': answers,
        },
      );
      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to submit quiz', originalError: e);
    }
  }

  /// Get leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard({
    String? subject,
    String? region,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.progress}/leaderboard',
        queryParameters: {
          if (subject != null) 'subject': subject,
          if (region != null) 'region': region,
          'limit': limit,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['leaderboard'] ?? []);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch leaderboard', originalError: e);
    }
  }

  /// Set auth token
  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
  }

  /// Clear auth token
  void clearAuthToken() {
    _apiClient.clearAuthToken();
  }
}
