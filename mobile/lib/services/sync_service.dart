import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/network/connectivity_service.dart';
import '../data/repositories/progress_repository.dart';

/// Service for background sync of progress events
class SyncService {
  final ProgressRepository _progressRepository;
  final ConnectivityService _connectivityService = ConnectivityService();
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService({required ProgressRepository progressRepository})
      : _progressRepository = progressRepository {
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
      final result = await _progressRepository.syncProgress();
      return result;
    } catch (e) {
      return (syncedCount: 0, failure: ServerFailure(e.toString()));
    } finally {
      _isSyncing = false;
    }
  }

  /// Get pending sync count
  Future<int> getPendingCount() async {
    return _progressRepository.getPendingSyncCount();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}
