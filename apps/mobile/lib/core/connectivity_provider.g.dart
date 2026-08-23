// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the device currently has any network connectivity. Feeds the
/// offline banner and sync status indicator (4.14) and the sync connectivity
/// trigger (4.12).

@ProviderFor(isOnline)
final isOnlineProvider = IsOnlineProvider._();

/// Whether the device currently has any network connectivity. Feeds the
/// offline banner and sync status indicator (4.14) and the sync connectivity
/// trigger (4.12).

final class IsOnlineProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the device currently has any network connectivity. Feeds the
  /// offline banner and sync status indicator (4.14) and the sync connectivity
  /// trigger (4.12).
  IsOnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOnlineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOnlineHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return isOnline(ref);
  }
}

String _$isOnlineHash() => r'9ed11d0dcdcf7e8aa3dc3d04b18a1602c93bfe24';
