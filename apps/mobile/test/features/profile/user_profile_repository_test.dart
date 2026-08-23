import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/local/app_database.dart';
import 'package:healthtrack/data/local/op_writer.dart';
import 'package:healthtrack/data/secure/secure_key_value_store.dart';
import 'package:healthtrack/features/profile/user_profile_materializer.dart';
import 'package:healthtrack/features/profile/user_profile_repository.dart';
import 'package:healthtrack/sync/entity_registry.dart';
import 'package:healthtrack/sync/entity_writer.dart';
import 'package:healthtrack/sync/local_materializer.dart';
import 'package:healthtrack/sync/sync_api.dart';
import 'package:healthtrack/sync/sync_cursor_store.dart';
import 'package:healthtrack/sync/sync_engine.dart';

class _InMemorySecureStore implements SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

class _FakeSyncApi implements SyncApi {
  BootstrapSnapshot? bootstrapSnapshot;
  int bootstrapCalls = 0;

  @override
  Future<List<PushOpResult>> push(List<PushOpRequest> ops) async => const [];

  @override
  Future<PullPage> pull({required int since, int? limit}) async {
    return const PullPage(ops: [], nextCursor: 0);
  }

  @override
  Future<BootstrapSnapshot> bootstrap() async {
    bootstrapCalls++;
    return bootstrapSnapshot ??
        const BootstrapSnapshot(entities: {}, cursor: 0);
  }
}

void main() {
  late AppDatabase db;
  late _FakeSyncApi api;
  late UserProfileRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final registry = EntityRegistry()
      ..register('user_profile', UserProfileMaterializer(db));
    final materializer = LocalMaterializer(db, registry);
    final opWriter = OpWriter(db, userId: 'user-1', deviceId: 'device-1');
    api = _FakeSyncApi();
    final syncEngine = SyncEngine(
      db: db,
      api: api,
      cursorStore: SyncCursorStore(_InMemorySecureStore()),
      materializer: materializer,
      registry: registry,
      userId: 'user-1',
    );
    repository = UserProfileRepository(
      db: db,
      entityWriter: EntityWriter(db, opWriter, materializer),
      syncEngine: syncEngine,
      userId: 'user-1',
    );
  });

  tearDown(() => db.close());

  test('ensureLoaded bootstraps when there is no local row yet', () async {
    api.bootstrapSnapshot = const BootstrapSnapshot(
      entities: {
        'user_profile': [
          {'id': 'user-1', 'display_name': 'Ada'},
        ],
      },
      cursor: 5,
    );

    final profile = await repository.ensureLoaded();

    expect(profile, isNotNull);
    expect(profile!.displayName, 'Ada');
    expect(api.bootstrapCalls, 1);
  });

  test('ensureLoaded does not bootstrap again once a row exists', () async {
    await repository.update({'display_name': 'Ada'});

    final profile = await repository.ensureLoaded();

    expect(profile!.displayName, 'Ada');
    expect(api.bootstrapCalls, 0);
  });

  test('update is reflected immediately by watch()', () async {
    final updates = repository.watch();
    final firstUpdate = updates.firstWhere((p) => p != null);

    await repository.update({'height_cm': 170.0});

    final profile = await firstUpdate;
    expect(profile!.heightCm, 170.0);
  });

  group('isOnboardingComplete', () {
    test('false when there is no profile at all', () {
      expect(isOnboardingComplete(null), isFalse);
    });

    test('false when a required field is missing', () async {
      await repository.update({'birth_date': '1990-01-01', 'height_cm': 170.0});
      final profile = await repository.ensureLoaded();

      expect(isOnboardingComplete(profile), isFalse);
    });

    test(
      'true once birth_date, sex_at_birth, and height_cm are all set',
      () async {
        await repository.update({
          'birth_date': '1990-01-01',
          'sex_at_birth': 'female',
          'height_cm': 170.0,
        });
        final profile = await repository.ensureLoaded();

        expect(isOnboardingComplete(profile), isTrue);
      },
    );
  });
}
