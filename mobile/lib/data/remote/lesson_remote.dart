import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';

/// Remote data source for lessons
class LessonRemote {
  final ApiClient _apiClient = ApiClient();

  /// Get available lesson packs
  Future<List<Map<String, dynamic>>> getLessonPacks({String? language}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.lessonPacks,
        queryParameters: language != null ? {'language': language} : null,
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['packs'] ?? []);
    } on AppException {
      // If server fails, try loading from assets as a fallback for initial content
      return _getInitialPacksFromAssets();
    } catch (e) {
      return _getInitialPacksFromAssets();
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
      // Fallback to asset if it matches a pre-baked pack
      return _getLessonsFromAsset(packId);
    } catch (e) {
      return _getLessonsFromAsset(packId);
    }
  }

  /// Download a lesson pack (returns the file path)
  Future<String> downloadPack(
    String packId, {
    void Function(int, int)? onProgress,
  }) async {
    try {
      final url = '${ApiConstants.downloadPack}/$packId';
      
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
      // Check if we can find it in our asset packs
      return _getQuizFromAsset(lessonId);
    } catch (e) {
      return _getQuizFromAsset(lessonId);
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
      // For adaptive quiz offline, we'd need locally stored question bank
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Internal: Get initial packs from assets
  Future<List<Map<String, dynamic>>> _getInitialPacksFromAssets() async {
    return [
      {
        'id': '8d89a456-11f8-472d-8687-111111111111',
        'subject': 'math',
        'level': 1,
        'size_mb': 0.0,
        'language': 'en',
      },
      {
        'id': '8d89a456-11f8-472d-8687-222222222222',
        'subject': 'english',
        'level': 1,
        'size_mb': 1.2,
        'language': 'en',
      },
    ];
  }

  /// Internal: Get lessons from asset file
  Future<List<Map<String, dynamic>>> _getLessonsFromAsset(String packId) async {
    try {
      final String manifestContent = await rootBundle.loadString('assets/lesson_packs/$packId.json');
      final Map<String, dynamic> data = json.decode(manifestContent);
      return List<Map<String, dynamic>>.from(data['lessons'] ?? []);
    } catch (e) {
      return [];
    }
  }

  /// Internal: Get quiz from asset file
  Future<List<Map<String, dynamic>>> _getQuizFromAsset(String lessonId) async {
    // This is a naive implementation: it assumes lessonId might be traceable within a pack
    // In a real app, we'd have a mapping. For now, try to find it in our pre-baked assets.
    try {
      final packs = [
        '8d89a456-11f8-472d-8687-111111111111',
        '8d89a456-11f8-472d-8687-222222222222'
      ];
      for (final packId in packs) {
        final String manifestContent = await rootBundle.loadString('assets/lesson_packs/$packId.json');
        final Map<String, dynamic> data = json.decode(manifestContent);
        final lessons = data['lessons'] as List;
        for (final lesson in lessons) {
          if (lesson['id'] == lessonId && lesson['quiz'] != null) {
            return List<Map<String, dynamic>>.from(lesson['quiz'] ?? []);
          }
        }
      }
    } catch (e) {
      // Silent error
    }
    return [];
  }

  /// Get download path for a pack
  Future<String> _getDownloadPath(String packId) async {
    final directory = await getApplicationDocumentsDirectory();
    return p.join(directory.path, 'downloads', '$packId.edupack');
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
