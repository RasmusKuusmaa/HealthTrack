// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(secureKeyValueStore)
final secureKeyValueStoreProvider = SecureKeyValueStoreProvider._();

final class SecureKeyValueStoreProvider
    extends
        $FunctionalProvider<
          SecureKeyValueStore,
          SecureKeyValueStore,
          SecureKeyValueStore
        >
    with $Provider<SecureKeyValueStore> {
  SecureKeyValueStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureKeyValueStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureKeyValueStoreHash();

  @$internal
  @override
  $ProviderElement<SecureKeyValueStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SecureKeyValueStore create(Ref ref) {
    return secureKeyValueStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureKeyValueStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureKeyValueStore>(value),
    );
  }
}

String _$secureKeyValueStoreHash() =>
    r'9b2948161fb8a2754d5d0a769f871760d8d4d6d7';

@ProviderFor(tokenStore)
final tokenStoreProvider = TokenStoreProvider._();

final class TokenStoreProvider
    extends $FunctionalProvider<TokenStore, TokenStore, TokenStore>
    with $Provider<TokenStore> {
  TokenStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenStoreHash();

  @$internal
  @override
  $ProviderElement<TokenStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TokenStore create(Ref ref) {
    return tokenStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenStore>(value),
    );
  }
}

String _$tokenStoreHash() => r'f252ab7bd9bc313d2e9c00b559e17badb9d8715f';

@ProviderFor(deviceId)
final deviceIdProvider = DeviceIdProvider._();

final class DeviceIdProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  DeviceIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceIdHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return deviceId(ref);
  }
}

String _$deviceIdHash() => r'e77511f49f58242b0ee9122e98f23661886d5c2f';

/// The shared `Dio` used for every authenticated API call, with
/// [AuthInterceptor] attached. Refreshing uses a separate, interceptor-free
/// `Dio` so a refresh call can never itself recurse through 401 handling.

@ProviderFor(apiDio)
final apiDioProvider = ApiDioProvider._();

/// The shared `Dio` used for every authenticated API call, with
/// [AuthInterceptor] attached. Refreshing uses a separate, interceptor-free
/// `Dio` so a refresh call can never itself recurse through 401 handling.

final class ApiDioProvider
    extends $FunctionalProvider<AsyncValue<Dio>, Dio, FutureOr<Dio>>
    with $FutureModifier<Dio>, $FutureProvider<Dio> {
  /// The shared `Dio` used for every authenticated API call, with
  /// [AuthInterceptor] attached. Refreshing uses a separate, interceptor-free
  /// `Dio` so a refresh call can never itself recurse through 401 handling.
  ApiDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiDioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiDioHash();

  @$internal
  @override
  $FutureProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Dio> create(Ref ref) {
    return apiDio(ref);
  }
}

String _$apiDioHash() => r'ca661c03ef65bffc9d37f8318329409abf5f57d1';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthRepository>,
          AuthRepository,
          FutureOr<AuthRepository>
        >
    with $FutureModifier<AuthRepository>, $FutureProvider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<AuthRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AuthRepository> create(Ref ref) {
    return authRepository(ref);
  }
}

String _$authRepositoryHash() => r'8531bf12951a1b5dbf4123f05ec810c12d7b74f0';

/// The signed-in user's id, read from the stored access token's `sub`
/// claim — `POST /auth/login` returns only tokens, not the user's id.

@ProviderFor(currentUserId)
final currentUserIdProvider = CurrentUserIdProvider._();

/// The signed-in user's id, read from the stored access token's `sub`
/// claim — `POST /auth/login` returns only tokens, not the user's id.

final class CurrentUserIdProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The signed-in user's id, read from the stored access token's `sub`
  /// claim — `POST /auth/login` returns only tokens, not the user's id.
  CurrentUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserIdHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return currentUserId(ref);
  }
}

String _$currentUserIdHash() => r'2ab130b884920e3b6f598fc901ea1f5803919e23';
