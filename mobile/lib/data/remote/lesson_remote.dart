import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';

/// Remote data source for lessons
class LessonRemote {
  final ApiClient _apiClient = ApiClient();

  /// Get all available lesson packs
  Future<List<Map<String, dynamic>>> getLessonPacks() async {
    try {
      final response = await _apiClient.get(ApiConstants.lessonPacks);
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['packs'] ?? []);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch lesson packs', originalError: e);
    }
  }

  /// Get lessons for a specific pack
  Future<List<Map<String, dynamic>>> getLessonsForPack(String packId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.lessonPacks}/$packId/lessons',
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['lessons'] ?? []);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch lessons', originalError: e);
    }
  }

  /// Download a lesson pack (returns the file path)
  Future<String> downloadPack(
    String packId, {
    void Function(int, int)? onProgress,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.downloadPack}/$packId';
      
      // Get download directory
      final savePath = await _getDownloadPath(packId);
      
      await _apiClient.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
      );
      
      return savePath;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to download pack', originalError: e);
    }
  }

  /// Get a specific lesson
  Future<Map<String, dynamic>> getLesson(String lessonId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.lessons}/$lessonId');
      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch lesson', originalError: e);
    }
  }

  /// Get quiz questions for a lesson
  Future<List<Map<String, dynamic>>> getQuizQuestions(String lessonId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.lessons}/$lessonId/quiz',
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['questions'] ?? []);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch quiz questions', originalError: e);
    }
  }

  /// Get adaptive quiz based on learner performance
  Future<List<Map<String, dynamic>>> getAdaptiveQuiz({
    required String learnerId,
    required String subject,
    int count = 5,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.lessons}/quiz/adaptive',
        queryParameters: {
          'learner_id': learnerId,
          'subject': subject,
          'count': count,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['questions'] ?? []);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch adaptive quiz', originalError: e);
    }
  }

  /// Get download path for a pack
  Future<String> _getDownloadPath(String packId) async {
    // This would use path_provider in real implementation
    return '/downloads/$packId.edupack';
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
