import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/network/api_providers.dart';
import '../data/local/app_database.dart';
import '../data/local/op_writer.dart';
import '../features/profile/user_profile_materializer.dart';
import '../features/weight/weight_entry_materializer.dart';
import 'entity_registry.dart';
import 'entity_writer.dart';
import 'local_materializer.dart';
import 'sync_api.dart';
import 'sync_cursor_store.dart';
import 'sync_engine.dart';

part 'sync_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

/// entity_type -> materializer, for every synced entity this build knows
/// about. Add a new entity's materializer here when it's built.
@riverpod
EntityRegistry entityRegistry(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return EntityRegistry()
    ..register('user_profile', UserProfileMaterializer(db))
    ..register('weight_entry', WeightEntryMaterializer(db));
}

@riverpod
LocalMaterializer localMaterializer(Ref ref) {
  return LocalMaterializer(
    ref.watch(appDatabaseProvider),
    ref.watch(entityRegistryProvider),
  );
}

@riverpod
Future<SyncApi> syncApi(Ref ref) async {
  final dio = await ref.watch(apiDioProvider.future);
  return DioSyncApi(dio);
}

@riverpod
Future<OpWriter> opWriter(Ref ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  final deviceId = await ref.watch(deviceIdProvider.future);
  return OpWriter(
    ref.watch(appDatabaseProvider),
    userId: userId,
    deviceId: deviceId,
  );
}

@riverpod
Future<EntityWriter> entityWriter(Ref ref) async {
  return EntityWriter(
    ref.watch(appDatabaseProvider),
    await ref.watch(opWriterProvider.future),
    ref.watch(localMaterializerProvider),
  );
}

@riverpod
Future<SyncEngine> syncEngine(Ref ref) async {
  return SyncEngine(
    db: ref.watch(appDatabaseProvider),
    api: await ref.watch(syncApiProvider.future),
    cursorStore: SyncCursorStore(ref.watch(secureKeyValueStoreProvider)),
    materializer: ref.watch(localMaterializerProvider),
    registry: ref.watch(entityRegistryProvider),
    userId: await ref.watch(currentUserIdProvider.future),
  );
}
