import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_status_provider.g.dart';

enum SyncPhase { idle, syncing, synced, error }

class SyncStatus {
  const SyncStatus._(this.phase, this.errorMessage);

  const SyncStatus.idle() : this._(SyncPhase.idle, null);
  const SyncStatus.syncing() : this._(SyncPhase.syncing, null);
  const SyncStatus.synced() : this._(SyncPhase.synced, null);
  const SyncStatus.error(String message) : this._(SyncPhase.error, message);

  final SyncPhase phase;
  final String? errorMessage;

  @override
  bool operator ==(Object other) =>
      other is SyncStatus &&
      other.phase == phase &&
      other.errorMessage == errorMessage;

  @override
  int get hashCode => Object.hash(phase, errorMessage);
}

/// The app's current sync phase, driven by whatever runs [SyncEngine] (the
/// trigger controller, a manual pull-to-refresh, etc.) via [markSyncing],
/// [markSynced], and [markError]. UI (the offline banner, a status icon)
/// only ever reads this — it never runs a sync itself.
@riverpod
class SyncStatusController extends _$SyncStatusController {
  @override
  SyncStatus build() => const SyncStatus.idle();

  void markSyncing() => state = const SyncStatus.syncing();

  void markSynced() => state = const SyncStatus.synced();

  void markError(String message) => state = SyncStatus.error(message);
}
