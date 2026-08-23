// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

/// entity_type -> materializer, for every synced entity this build knows
/// about. Add a new entity's materializer here when it's built.

@ProviderFor(entityRegistry)
final entityRegistryProvider = EntityRegistryProvider._();

/// entity_type -> materializer, for every synced entity this build knows
/// about. Add a new entity's materializer here when it's built.

final class EntityRegistryProvider
    extends $FunctionalProvider<EntityRegistry, EntityRegistry, EntityRegistry>
    with $Provider<EntityRegistry> {
  /// entity_type -> materializer, for every synced entity this build knows
  /// about. Add a new entity's materializer here when it's built.
  EntityRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entityRegistryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entityRegistryHash();

  @$internal
  @override
  $ProviderElement<EntityRegistry> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EntityRegistry create(Ref ref) {
    return entityRegistry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntityRegistry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntityRegistry>(value),
    );
  }
}

String _$entityRegistryHash() => r'faf9e64ef1557fc656e17612a3111018d944b479';

@ProviderFor(localMaterializer)
final localMaterializerProvider = LocalMaterializerProvider._();

final class LocalMaterializerProvider
    extends
        $FunctionalProvider<
          LocalMaterializer,
          LocalMaterializer,
          LocalMaterializer
        >
    with $Provider<LocalMaterializer> {
  LocalMaterializerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localMaterializerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localMaterializerHash();

  @$internal
  @override
  $ProviderElement<LocalMaterializer> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalMaterializer create(Ref ref) {
    return localMaterializer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalMaterializer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalMaterializer>(value),
    );
  }
}

String _$localMaterializerHash() => r'61d579143d7283d1c11ff1b86c2389e0a05f1e57';

@ProviderFor(syncApi)
final syncApiProvider = SyncApiProvider._();

final class SyncApiProvider
    extends $FunctionalProvider<AsyncValue<SyncApi>, SyncApi, FutureOr<SyncApi>>
    with $FutureModifier<SyncApi>, $FutureProvider<SyncApi> {
  SyncApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncApiHash();

  @$internal
  @override
  $FutureProviderElement<SyncApi> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SyncApi> create(Ref ref) {
    return syncApi(ref);
  }
}

String _$syncApiHash() => r'2803e046640aed51a1d7ef8a16f1088bba57072c';

@ProviderFor(opWriter)
final opWriterProvider = OpWriterProvider._();

final class OpWriterProvider
    extends
        $FunctionalProvider<AsyncValue<OpWriter>, OpWriter, FutureOr<OpWriter>>
    with $FutureModifier<OpWriter>, $FutureProvider<OpWriter> {
  OpWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'opWriterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$opWriterHash();

  @$internal
  @override
  $FutureProviderElement<OpWriter> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<OpWriter> create(Ref ref) {
    return opWriter(ref);
  }
}

String _$opWriterHash() => r'4779ea8d11c12042e957f414095a52935c7ad1f6';

@ProviderFor(entityWriter)
final entityWriterProvider = EntityWriterProvider._();

final class EntityWriterProvider
    extends
        $FunctionalProvider<
          AsyncValue<EntityWriter>,
          EntityWriter,
          FutureOr<EntityWriter>
        >
    with $FutureModifier<EntityWriter>, $FutureProvider<EntityWriter> {
  EntityWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entityWriterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entityWriterHash();

  @$internal
  @override
  $FutureProviderElement<EntityWriter> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EntityWriter> create(Ref ref) {
    return entityWriter(ref);
  }
}

String _$entityWriterHash() => r'1b986d2a7ccfcac9e7394e8967df866d9195db36';

@ProviderFor(syncEngine)
final syncEngineProvider = SyncEngineProvider._();

final class SyncEngineProvider
    extends
        $FunctionalProvider<
          AsyncValue<SyncEngine>,
          SyncEngine,
          FutureOr<SyncEngine>
        >
    with $FutureModifier<SyncEngine>, $FutureProvider<SyncEngine> {
  SyncEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncEngineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncEngineHash();

  @$internal
  @override
  $FutureProviderElement<SyncEngine> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SyncEngine> create(Ref ref) {
    return syncEngine(ref);
  }
}

String _$syncEngineHash() => r'43922dbdf72ffcfa0dc6c444cf3f66137bea571a';
