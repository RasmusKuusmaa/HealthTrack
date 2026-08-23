// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Placeholder auth state until 4.18 (secure token storage) and 4.21 (auth
/// screens) land — the router only needs to know whether to send someone to
/// the sign-in screen or into the app shell.

@ProviderFor(IsAuthenticated)
final isAuthenticatedProvider = IsAuthenticatedProvider._();

/// Placeholder auth state until 4.18 (secure token storage) and 4.21 (auth
/// screens) land — the router only needs to know whether to send someone to
/// the sign-in screen or into the app shell.
final class IsAuthenticatedProvider
    extends $NotifierProvider<IsAuthenticated, bool> {
  /// Placeholder auth state until 4.18 (secure token storage) and 4.21 (auth
  /// screens) land — the router only needs to know whether to send someone to
  /// the sign-in screen or into the app shell.
  IsAuthenticatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthenticatedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  IsAuthenticated create() => IsAuthenticated();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'dde3efbe98d9f381cac1c608da03e8c17dfeb192';

/// Placeholder auth state until 4.18 (secure token storage) and 4.21 (auth
/// screens) land — the router only needs to know whether to send someone to
/// the sign-in screen or into the app shell.

abstract class _$IsAuthenticated extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
