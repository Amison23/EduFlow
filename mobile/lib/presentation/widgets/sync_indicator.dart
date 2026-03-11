import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sync/sync_cubit.dart';

/// Indicator showing sync status
class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, state) {
        return InkWell(
          onTap: state.hasPending ? () => context.read<SyncCubit>().syncNow() : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(state),
                if (state.hasPending && !state.isSyncing) ...[
                  const SizedBox(width: 4),
                  Text(
                    '${state.pendingCount}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(SyncState state) {
    if (state.isSyncing) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }

    if (state.hasPending) {
      return const Icon(Icons.sync, size: 18, color: Colors.white);
    }

    return const Icon(Icons.cloud_done, size: 18, color: Colors.white);
  }
}
