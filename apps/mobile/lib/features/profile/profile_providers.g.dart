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
