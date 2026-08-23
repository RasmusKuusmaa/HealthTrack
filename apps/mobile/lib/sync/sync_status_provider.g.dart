// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's current sync phase, driven by whatever runs [SyncEngine] (the
/// trigger controller, a manual pull-to-refresh, etc.) via [markSyncing],
/// [markSynced], and [markError]. UI (the offline banner, a status icon)
/// only ever reads this — it never runs a sync itself.

@ProviderFor(SyncStatusController)
final syncStatusControllerProvider = SyncStatusControllerProvider._();

/// The app's current sync phase, driven by whatever runs [SyncEngine] (the
/// trigger controller, a manual pull-to-refresh, etc.) via [markSyncing],
/// [markSynced], and [markError]. UI (the offline banner, a status icon)
/// only ever reads this — it never runs a sync itself.
final class SyncStatusControllerProvider
    extends $NotifierProvider<SyncStatusController, SyncStatus> {
  /// The app's current sync phase, driven by whatever runs [SyncEngine] (the
  /// trigger controller, a manual pull-to-refresh, etc.) via [markSyncing],
  /// [markSynced], and [markError]. UI (the offline banner, a status icon)
  /// only ever reads this — it never runs a sync itself.
  SyncStatusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStatusControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStatusControllerHash();

  @$internal
  @override
  SyncStatusController create() => SyncStatusController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStatus>(value),
    );
  }
}

String _$syncStatusControllerHash() =>
    r'6144b9fdbe33a0b4d8feae6ff4945498f7112e12';

/// The app's current sync phase, driven by whatever runs [SyncEngine] (the
/// trigger controller, a manual pull-to-refresh, etc.) via [markSyncing],
/// [markSynced], and [markError]. UI (the offline banner, a status icon)
/// only ever reads this — it never runs a sync itself.

abstract class _$SyncStatusController extends $Notifier<SyncStatus> {
  SyncStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SyncStatus, SyncStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SyncStatus, SyncStatus>,
              SyncStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
