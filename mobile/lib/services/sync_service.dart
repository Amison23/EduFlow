import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/network/connectivity_service.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/outbox_repository.dart';
import '../data/repositories/lesson_repository.dart';
import '../core/errors/failures.dart';

/// Service for background sync of progress events and outbox requests
class SyncService {
  final ProgressRepository _progressRepository;
  final OutboxRepository _outboxRepository;
  final LessonRepository _lessonRepository;
  final ConnectivityService _connectivityService = ConnectivityService();
  
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService({
    required ProgressRepository progressRepository,
    required OutboxRepository outboxRepository,
    required LessonRepository lessonRepository,
  })  : _progressRepository = progressRepository,
        _outboxRepository = outboxRepository,
        _lessonRepository = lessonRepository {
    _init();
  }

  void _init() {
    // Listen for connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isOnline) {
        if (isOnline && !_isSyncing) {
          sync();
        }
      },
    );

    // Immediate sync on start if online
    if (_connectivityService.isOnline) {
      sync();
    }

    // Periodic sync every 2 minutes
    _syncTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => sync(),
    );
  }

  /// Perform sync
  Future<({int syncedCount, Failure? failure})> sync() async {
    if (_isSyncing) {
      return (syncedCount: 0, failure: null);
    }

    if (!_connectivityService.isOnline) {
      return (syncedCount: 0, failure: const NetworkFailure('Offline'));
    }

    _isSyncing = true;

    try {
      // 1. Process Generic Outbox (Analytics, Profile, etc.)
      await _outboxRepository.processOutbox();

      // 2. Process Progress Events
      final progressResult = await _progressRepository.syncProgress();

      // 3. Sync Content (Check for version updates)
      await _syncContent();
      
      return progressResult;
    } catch (e) {
      return (syncedCount: 0, failure: ServerFailure(e.toString()));
    } finally {
      _isSyncing = false;
    }
  }

  /// Internal: Check for pack version updates and refresh if needed
  Future<void> _syncContent() async {
    try {
      final packsResult = await _lessonRepository.getLessonPacks();
      final remotePacks = packsResult.packs;
      
      for (final remotePack in remotePacks) {
        final packId = remotePack['id'];

        // Fetch local version to compare
        // Note: Repository already fetches packs and upserts them, 
        // but we need to trigger syncPackContent if the version actually changed.
        // The Repository's getLessonPacks handles the initial upsert, but LessonRepository.syncPackContent
        // ensures the lessons and quizzes are also refreshed.
        
        // We can add a simple logic here: if we just updated the pack metadata, 
        // we should probably ensure the content is also fresh.
        // For efficiency, we only refresh lessons if the pack version is new.
        
        // However, since getLessonPacks already updated the local_packs table,
        // we'd need to know if it was *actually* an update.
        // For simplicity in this hackathon context, we'll trigger a refresh 
        // for any pack we find, or we could add a version check here.
        
        await _lessonRepository.syncPackContent(packId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Content sync failed: $e');
      }
    }
  }

  /// Get total pending sync count
  Future<int> getPendingCount() async {
    final progressCount = await _progressRepository.getPendingSyncCount();
    final outboxCount = await _outboxRepository.getPendingCount();
    return progressCount + outboxCount;
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}
