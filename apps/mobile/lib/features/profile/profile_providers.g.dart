// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userProfileRepository)
final userProfileRepositoryProvider = UserProfileRepositoryProvider._();

final class UserProfileRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProfileRepository>,
          UserProfileRepository,
          FutureOr<UserProfileRepository>
        >
    with
        $FutureModifier<UserProfileRepository>,
        $FutureProvider<UserProfileRepository> {
  UserProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<UserProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserProfileRepository> create(Ref ref) {
    return userProfileRepository(ref);
  }
}

String _$userProfileRepositoryHash() =>
    r'56ab2800c0d0774a2e747c93bdf72b853a0e910c';

/// The signed-in user's preferred unit system ('metric' or 'imperial'),
/// updating live as the profile changes locally. Null until the profile has
/// ever been loaded.

@ProviderFor(currentUnitSystem)
final currentUnitSystemProvider = CurrentUnitSystemProvider._();

/// The signed-in user's preferred unit system ('metric' or 'imperial'),
/// updating live as the profile changes locally. Null until the profile has
/// ever been loaded.

final class CurrentUnitSystemProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// The signed-in user's preferred unit system ('metric' or 'imperial'),
  /// updating live as the profile changes locally. Null until the profile has
  /// ever been loaded.
  CurrentUnitSystemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUnitSystemProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUnitSystemHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return currentUnitSystem(ref);
  }
}

String _$currentUnitSystemHash() => r'208a3c03fdc640d6495fe0a602ec976496bdbb37';
