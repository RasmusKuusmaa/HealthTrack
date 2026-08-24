// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(weightRepository)
final weightRepositoryProvider = WeightRepositoryProvider._();

final class WeightRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeightRepository>,
          WeightRepository,
          FutureOr<WeightRepository>
        >
    with $FutureModifier<WeightRepository>, $FutureProvider<WeightRepository> {
  WeightRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weightRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weightRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<WeightRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WeightRepository> create(Ref ref) {
    return weightRepository(ref);
  }
}

String _$weightRepositoryHash() => r'f2516ccd56fd4930d4dac72ff7e7dc24f6d6a055';
