import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';

/// Remote data source for community features
class CommunityRemote {
  final ApiClient _apiClient = ApiClient();

  /// Get available study groups
  Future<List<Map<String, dynamic>>> getStudyGroups({String? subject}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.studyGroups,
        queryParameters: subject != null ? {'subject': subject} : null,
      );
      return List<Map<String, dynamic>>.from(response.data as List);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch study groups', originalError: e);
    }
  }

  /// Create a new study group
  Future<Map<String, dynamic>> createStudyGroup({
    required String name,
    required String subject,
    int? maxMembers,
    bool isPublic = true,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.studyGroups,
        data: {
          'name': name,
          'subject': subject,
          'max_members': maxMembers,
          'is_public': isPublic,
        },
      );
      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to create study group', originalError: e);
    }
  }

  /// Join a study group
  Future<bool> joinStudyGroup(String groupId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.studyGroups}/$groupId/join',
      );
      final data = response.data as Map<String, dynamic>;
      return data['success'] == true;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to join study group', originalError: e);
    }
  }

  /// Find potential study peers
  Future<List<Map<String, dynamic>>> findPeers() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.findPeers,
      );
      return List<Map<String, dynamic>>.from(response.data as List);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to find study peers', originalError: e);
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
