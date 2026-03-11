import '../../core/errors/failures.dart';
import '../../core/network/connectivity_service.dart';
import '../local/database.dart';
import '../local/daos/lesson_dao.dart';
import '../remote/lesson_remote.dart';

/// Repository for lessons
class LessonRepository {
  final Database _localDatabase;
  final LessonRemote _lessonRemote;
  final ConnectivityService _connectivityService = ConnectivityService();

  LessonRepository({
    required Database localDatabase,
    required LessonRemote lessonRemote,
  })  : _localDatabase = localDatabase,
        _lessonRemote = lessonRemote;

  /// Get available lesson packs (from cache or server)
  Future<({List<Map<String, dynamic>> packs, Failure? failure})> getLessonPacks() async {
    // If online, fetch from server
    if (_connectivityService.isOnline) {
      try {
        final packs = await _lessonRemote.getLessonPacks();
        return (packs: packs, failure: null);
      } catch (e) {
        return (packs: [], failure: ServerFailure(e.toString()));
      }
    }
    
    // Return empty list when offline (packs would be cached)
    return (packs: [], failure: const NetworkFailure('Offline'));
  }

  /// Get lessons for a pack
  Future<({List<Map<String, dynamic>> lessons, Failure? failure})> getLessonsForPack(String packId) async {
    // Check local first
    final lessonDao = LessonDao(_localDatabase);
    final localLessons = await lessonDao.getLessonsForPack(packId);
    
    if (localLessons.isNotEmpty) {
      return (lessons: localLessons, failure: null);
    }
    
    // If online, fetch from server
    if (_connectivityService.isOnline) {
      try {
        final lessons = await _lessonRemote.getLessonsForPack(packId);
        
        // Cache lessons locally
        for (final lesson in lessons) {
          await lessonDao.upsertLesson(
            id: lesson['id'],
            packId: packId,
            title: lesson['title'],
            sequence: lesson['sequence'],
            content: lesson['content'] ?? '',
            audioPath: lesson['audio_url'],
          );
        }
        
        return (lessons: lessons, failure: null);
      } catch (e) {
        return (lessons: [], failure: ServerFailure(e.toString()));
      }
    }
    
    return (lessons: [], failure: const NetworkFailure('Offline - no cached lessons'));
  }

  /// Download a lesson pack
  Future<({bool success, Failure? failure})> downloadPack(
    String packId, {
    void Function(int, int)? onProgress,
  }) async {
    if (!_connectivityService.isOnline) {
      return (success: false, failure: const NetworkFailure('No internet connection'));
    }
    
    try {
      await _lessonRemote.downloadPack(packId, onProgress: onProgress);
      return (success: true, failure: null);
    } catch (e) {
      return (success: false, failure: ServerFailure(e.toString()));
    }
  }

  /// Get a specific lesson
  Future<({Map<String, dynamic>? lesson, Failure? failure})> getLesson(String lessonId) async {
    final lessonDao = LessonDao(_localDatabase);
    
    // Check local first
    final localLesson = await lessonDao.getLesson(lessonId);
    if (localLesson != null) {
      return (lesson: localLesson, failure: null);
    }
    
    // If online, fetch from server
    if (_connectivityService.isOnline) {
      try {
        final lesson = await _lessonRemote.getLesson(lessonId);
        return (lesson: lesson, failure: null);
      } catch (e) {
        return (lesson: null, failure: ServerFailure(e.toString()));
      }
    }
    
    return (lesson: null, failure: const NetworkFailure('Offline'));
  }

  /// Get quiz questions for a lesson
  Future<({List<Map<String, dynamic>> questions, Failure? failure})> getQuizQuestions(String lessonId) async {
    if (!_connectivityService.isOnline) {
      return (questions: [], failure: const NetworkFailure('Offline'));
    }
    
    try {
      final questions = await _lessonRemote.getQuizQuestions(lessonId);
      return (questions: questions, failure: null);
    } catch (e) {
      return (questions: [], failure: ServerFailure(e.toString()));
    }
  }

  /// Get adaptive quiz
  Future<({List<Map<String, dynamic>> questions, Failure? failure})> getAdaptiveQuiz({
    required String learnerId,
    required String subject,
    int count = 5,
  }) async {
    if (!_connectivityService.isOnline) {
      return (questions: [], failure: const NetworkFailure('Offline'));
    }
    
    try {
      final questions = await _lessonRemote.getAdaptiveQuiz(
        learnerId: learnerId,
        subject: subject,
        count: count,
      );
      return (questions: questions, failure: null);
    } catch (e) {
      return (questions: [], failure: ServerFailure(e.toString()));
    }
  }

  /// Check if pack is downloaded
  Future<bool> isPackDownloaded(String packId) async {
    final lessonDao = LessonDao(_localDatabase);
    return lessonDao.isPackDownloaded(packId);
  }

  /// Set auth token
  void setAuthToken(String token) {
    _lessonRemote.setAuthToken(token);
  }

  /// Clear auth token
  void clearAuthToken() {
    _lessonRemote.clearAuthToken();
  }
}
