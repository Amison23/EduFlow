import 'dart:async';
import '../core/network/connectivity_service.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/outbox_repository.dart';
import '../core/errors/failures.dart';

/// Service for background sync of progress events and outbox requests
class SyncService {
  final ProgressRepository _progressRepository;
  final OutboxRepository _outboxRepository;
  final ConnectivityService _connectivityService = ConnectivityService();
  
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService({
    required ProgressRepository progressRepository,
    required OutboxRepository outboxRepository,
  })  : _progressRepository = progressRepository,
        _outboxRepository = outboxRepository {
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

    // Periodic sync every 5 minutes
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
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
      
      return progressResult;
    } catch (e) {
      return (syncedCount: 0, failure: ServerFailure(e.toString()));
    } finally {
      _isSyncing = false;
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
