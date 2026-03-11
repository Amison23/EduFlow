import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../services/sync_service.dart';

part 'sync_state.dart';

/// Cubit for sync state management
class SyncCubit extends Cubit<SyncState> {
  final SyncService _syncService;
  final ProgressRepository _progressRepository;

  SyncCubit({
    required SyncService syncService,
    required ProgressRepository progressRepository,
  })  : _syncService = syncService,
        _progressRepository = progressRepository,
        super(const SyncState());

  /// Initialize sync
  Future<void> init() async {
    final pendingCount = await _progressRepository.getPendingSyncCount();
    final lastSyncTime = _progressRepository.getLastSyncTime();
    
    emit(state.copyWith(
      pendingCount: pendingCount,
      lastSyncTime: lastSyncTime,
      status: pendingCount > 0 ? SyncStatus.pending : SyncStatus.synced,
    ));
  }

  /// Sync now
  Future<void> syncNow() async {
    if (state.status == SyncStatus.syncing) return;
    
    emit(state.copyWith(status: SyncStatus.syncing));
    
    final result = await _syncService.sync();
    
    if (result.syncedCount > 0) {
      emit(state.copyWith(
        status: SyncStatus.synced,
        pendingCount: result.syncedCount,
        lastSyncTime: DateTime.now(),
        lastError: null,
      ));
    } else if (result.failure != null) {
      emit(state.copyWith(
        status: SyncStatus.error,
        lastError: result.failure!.message,
      ));
    } else {
      emit(state.copyWith(status: SyncStatus.synced));
    }
  }

  /// Check pending sync count
  Future<void> checkPending() async {
    final pendingCount = await _progressRepository.getPendingSyncCount();
    
    emit(state.copyWith(
      pendingCount: pendingCount,
      status: pendingCount > 0 ? SyncStatus.pending : SyncStatus.synced,
    ));
  }
}
