part of 'sync_cubit.dart';

/// Sync status enum
enum SyncStatus {
  initial,
  synced,
  pending,
  syncing,
  error,
}

/// Sync state
class SyncState {
  final SyncStatus status;
  final int pendingCount;
  final DateTime? lastSyncTime;
  final String? lastError;

  const SyncState({
    this.status = SyncStatus.initial,
    this.pendingCount = 0,
    this.lastSyncTime,
    this.lastError,
  });

  bool get isOnline => status != SyncStatus.error;
  bool get hasPending => pendingCount > 0;
  bool get isSyncing => status == SyncStatus.syncing;

  SyncState copyWith({
    SyncStatus? status,
    int? pendingCount,
    DateTime? lastSyncTime,
    String? lastError,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastError: lastError ?? this.lastError,
    );
  }
}
