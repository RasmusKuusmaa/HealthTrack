import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sync/sync_status_provider.dart';

/// A small icon summarizing the current sync phase, meant for an app bar.
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusControllerProvider);
    final theme = Theme.of(context);

    return switch (status.phase) {
      SyncPhase.idle => const SizedBox.shrink(),
      SyncPhase.syncing => SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.primary,
        ),
      ),
      SyncPhase.synced => Icon(
        Icons.cloud_done,
        size: 18,
        color: theme.colorScheme.primary,
      ),
      SyncPhase.error => Tooltip(
        message: status.errorMessage ?? 'Sync failed',
        child: Icon(Icons.cloud_off, size: 18, color: theme.colorScheme.error),
      ),
    };
  }
}
