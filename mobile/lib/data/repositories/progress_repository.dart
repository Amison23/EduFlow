import 'package:uuid/uuid.dart';
import '../../core/errors/failures.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/utils/date_utils.dart' as app_date;
import '../local/database.dart';
import '../local/daos/progress_dao.dart';
import '../local/hive_boxes.dart';
import '../remote/progress_remote.dart';
import '../../services/tflite_quiz_service.dart';

/// Repository for progress tracking
class ProgressRepository {
  final AppDatabase _localDatabase;
  final ProgressRemote _progressRemote;
  final ConnectivityService _connectivityService = ConnectivityService();
  final _uuid = const Uuid();

  ProgressRepository({
    required AppDatabase localDatabase,
    required ProgressRemote progressRemote,
  })  : _localDatabase = localDatabase,
        _progressRemote = progressRemote;

  /// Log a progress event (always local first)
  Future<void> logProgressEvent({
    required String lessonId,
    required String eventType,
    double? score,
  }) async {
    final progressDao = ProgressDao(_localDatabase);
    final now = DateTime.now();
    
    await progressDao.insertProgress(
      id: _uuid.v4(),
      lessonId: lessonId,
      eventType: eventType,
      score: score,
      deviceTimestamp: app_date.DateUtils.toUnixTimestamp(now),
    );
    
    // Try to sync if online
    if (_connectivityService.isOnline) {
      await syncProgress();
    }
  }

  /// Sync progress to server
  Future<({int syncedCount, Failure? failure})> syncProgress() async {
    final progressDao = ProgressDao(_localDatabase);
    final learnerId = HiveBoxes.getLearnerId();
    
    if (learnerId == null) {
      return (syncedCount: 0, failure: const AuthFailure('Not authenticated'));
    }
    
    if (!_connectivityService.isOnline) {
      return (syncedCount: 0, failure: const NetworkFailure('Offline'));
    }
    
    try {
      final unsyncedEvents = await progressDao.getUnsyncedEvents();
      
      if (unsyncedEvents.isEmpty) {
        return (syncedCount: 0, failure: null);
      }
      
      // Convert to API format
      final events = unsyncedEvents.map((e) => {
        'id': e['id'],
        'lesson_id': e['lesson_id'],
        'event_type': e['event_type'],
        'score': e['score'],
        'device_ts': e['device_ts'],
      }).toList();
      
      await _progressRemote.syncProgress(
        learnerId: learnerId,
        events: events,
      );
      
      // Mark as synced
      final syncedIds = unsyncedEvents.map((e) => e['id'] as String).toList();
      await progressDao.markAsSynced(syncedIds);
      
      // Update last sync time
      await HiveBoxes.setLastSyncTime(
        app_date.DateUtils.toUnixTimestamp(DateTime.now()),
      );
      
      return (syncedCount: syncedIds.length, failure: null);
    } catch (e) {
      return (syncedCount: 0, failure: ServerFailure(e.toString()));
    }
  }

  /// Get count of pending sync items
  Future<int> getPendingSyncCount() async {
    final progressDao = ProgressDao(_localDatabase);
    return progressDao.getUnsyncedCount();
  }

  /// Get progress from server
  Future<({Map<String, dynamic>? progress, Failure? failure})> getProgress() async {
    final learnerId = HiveBoxes.getLearnerId();
    
    if (learnerId == null) {
      return (progress: null, failure: const AuthFailure('Not authenticated'));
    }
    
    if (!_connectivityService.isOnline) {
      return (progress: null, failure: const NetworkFailure('Offline'));
    }
    
    try {
      final events = await _progressRemote.getProgress(learnerId);
      
      // Calculate total points for UI summary
      int totalPoints = 0;
      for (var event in events) {
        if (event['event_type'] == 'quiz_completed') {
          totalPoints += (event['score'] as num? ?? 0).toInt() * 10; // Simple points logic
        }
      }

      return (
        progress: {
          'total_points': totalPoints,
          'events': events,
        }, 
        failure: null
      );
    } catch (e) {
      return (progress: null, failure: ServerFailure(e.toString()));
    }
  }

  /// Initialize mastery from server (for cross-device sync)
  Future<void> initializeMasteryFromServer(TfliteQuizService quizService) async {
    final learnerId = HiveBoxes.getLearnerId();
    if (learnerId == null) return;

    try {
      final events = await _progressRemote.getProgress(learnerId);
      quizService.initializeFromEvents(events);
    } catch (_) {
      // Background initialization failures are silent
    }
  }

  /// Get subject progress
  Future<({Map<String, dynamic>? progress, Failure? failure})> getSubjectProgress(String subject) async {
    final learnerId = HiveBoxes.getLearnerId();
    
    if (learnerId == null) {
      return (progress: null, failure: const AuthFailure('Not authenticated'));
    }
    
    if (!_connectivityService.isOnline) {
      return (progress: null, failure: const NetworkFailure('Offline'));
    }
    
    try {
      final progress = await _progressRemote.getSubjectProgress(learnerId, subject);
      return (progress: progress, failure: null);
    } catch (e) {
      return (progress: null, failure: ServerFailure(e.toString()));
    }
  }

  /// Get learner streak
  Future<({int streak, Failure? failure})> getStreak() async {
    final learnerId = HiveBoxes.getLearnerId();
    
    if (learnerId == null) {
      return (streak: 0, failure: const AuthFailure('Not authenticated'));
    }
    
    if (!_connectivityService.isOnline) {
      return (streak: 0, failure: const NetworkFailure('Offline'));
    }
    
    try {
      final streak = await _progressRemote.getStreak(learnerId);
      return (streak: streak, failure: null);
    } catch (e) {
      return (streak: 0, failure: ServerFailure(e.toString()));
    }
  }

  /// Submit quiz answers
  Future<({Map<String, dynamic>? result, Failure? failure})> submitQuizAnswers({
    required String lessonId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final learnerId = HiveBoxes.getLearnerId();
    
    if (learnerId == null) {
      return (result: null, failure: const AuthFailure('Not authenticated'));
    }
    
    if (!_connectivityService.isOnline) {
      return (result: null, failure: const NetworkFailure('Offline'));
    }
    
    try {
      final result = await _progressRemote.submitQuizAnswers(
        learnerId: learnerId,
        lessonId: lessonId,
        answers: answers,
      );
      
      // Log the quiz completion
      final score = result['score'] as double?;
      await logProgressEvent(
        lessonId: lessonId,
        eventType: 'quiz_completed',
        score: score,
      );
      
      return (result: result, failure: null);
    } catch (e) {
      return (result: null, failure: ServerFailure(e.toString()));
    }
  }

  /// Get last sync time
  DateTime? getLastSyncTime() {
    final timestamp = HiveBoxes.getLastSyncTime();
    if (timestamp == null) return null;
    return app_date.DateUtils.fromUnixTimestamp(timestamp);
  }

  /// Set auth token
  void setAuthToken(String token) {
    _progressRemote.setAuthToken(token);
  }

  /// Clear auth token
  void clearAuthToken() {
    _progressRemote.clearAuthToken();
  }
}
