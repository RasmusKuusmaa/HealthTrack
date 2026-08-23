import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/local/app_database.dart';
import 'package:healthtrack/data/local/op_writer.dart';
import 'package:healthtrack/data/secure/secure_key_value_store.dart';
import 'package:healthtrack/domain/op_type.dart';
import 'package:healthtrack/sync/entity_materializer.dart';
import 'package:healthtrack/sync/entity_registry.dart';
import 'package:healthtrack/sync/local_materializer.dart';
import 'package:healthtrack/sync/sync_api.dart';
import 'package:healthtrack/sync/sync_cursor_store.dart';
import 'package:healthtrack/sync/sync_engine.dart';

class _InMemorySecureStore implements SecureKeyValueStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

class _FakeEntityMaterializer implements EntityMaterializer {
  final projection = <String, Map<String, dynamic>>{};

  @override
  Future<void> applyCreateOrUpdate({
    required String entityId,
    required String userId,
    required Map<String, dynamic> fields,
  }) async {
    projection.putIfAbsent(entityId, () => {}).addAll(fields);
  }

  @override
  Future<void> applyDelete({
    required String entityId,
    required DateTime deletedAt,
  }) async {
    projection.putIfAbsent(entityId, () => {})['deleted_at'] = deletedAt
        .toIso8601String();
  }
}

class _FakeSyncApi implements SyncApi {
  List<PushOpRequest>? lastPushed;
  List<PushOpResult> Function(List<PushOpRequest> ops)? onPush;
  final List<PullPage> pullPages = [];
  int pullCalls = 0;

  @override
  Future<List<PushOpResult>> push(List<PushOpRequest> ops) async {
    lastPushed = ops;
    return onPush?.call(ops) ?? const [];
  }

  @override
  Future<PullPage> pull({required int since, int? limit}) async {
    final page = pullCalls < pullPages.length
        ? pullPages[pullCalls]
        : const PullPage(ops: [], nextCursor: 0);
    pullCalls++;
    return page;
  }
}

void main() {
  late AppDatabase db;
  late OpWriter opWriter;
  late _FakeSyncApi api;
  late SyncCursorStore cursorStore;
  late _FakeEntityMaterializer fakeEntity;
  late SyncEngine engine;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    opWriter = OpWriter(
      db,
      userId: 'user-1',
      deviceId: 'device-1',
      now: () => DateTime.utc(2026, 1, 1),
    );
    api = _FakeSyncApi();
    cursorStore = SyncCursorStore(_InMemorySecureStore());
    fakeEntity = _FakeEntityMaterializer();
    final registry = EntityRegistry()..register('weight_entry', fakeEntity);
    engine = SyncEngine(
      db: db,
      api: api,
      cursorStore: cursorStore,
      materializer: LocalMaterializer(db, registry),
      userId: 'user-1',
    );
  });

  tearDown(() => db.close());

  group('push', () {
    test('does nothing when there are no unsynced ops', () async {
      await engine.push();
      expect(api.lastPushed, isNull);
    });

    test(
      'sends unsynced ops and marks them synced with the returned server_seq',
      () async {
        final clientOpId = await opWriter.write(
          entityType: 'weight_entry',
          entityId: 'e1',
          opType: OpType.create,
          payload: '{"weight_kg": 80}',
        );
        api.onPush = (ops) => [
          PushOpResult(clientOpId: clientOpId, serverSeq: 42),
        ];

        await engine.push();

        expect(api.lastPushed, hasLength(1));
        expect(api.lastPushed!.single.clientOpId, clientOpId);

        final row = await (db.select(
          db.operations,
        )..where((t) => t.clientOpId.equals(clientOpId))).getSingle();
        expect(row.synced, isTrue);
        expect(row.serverSeq, 42);
      },
    );

    test('does not resend an already-synced op', () async {
      final clientOpId = await opWriter.write(
        entityType: 'weight_entry',
        entityId: 'e1',
        opType: OpType.create,
        payload: '{}',
      );
      api.onPush = (ops) => [
        PushOpResult(clientOpId: clientOpId, serverSeq: 1),
      ];
      await engine.push();

      api.lastPushed = null;
      await engine.push();

      expect(api.lastPushed, isNull);
    });
  });

  group('pull', () {
    test('materializes every op in a page and advances the cursor', () async {
      api.pullPages.add(
        PullPage(
          ops: [
            PulledOp(
              serverSeq: 1,
              clientOpId: 'remote-1',
              entityType: 'weight_entry',
              entityId: 'e1',
              opType: 'create',
              payload: const {'weight_kg': 80},
              deviceId: 'device-2',
              clientTs: DateTime.utc(2026, 1, 1),
            ),
          ],
          nextCursor: 1,
        ),
      );

      await engine.pull();

      expect(fakeEntity.projection['e1'], {'weight_kg': 80});
      expect(await cursorStore.read(), 1);
    });

    test('pages until an empty page is returned', () async {
      api.pullPages.addAll([
        PullPage(
          ops: [
            PulledOp(
              serverSeq: 1,
              clientOpId: 'remote-1',
              entityType: 'weight_entry',
              entityId: 'e1',
              opType: 'create',
              payload: const {'weight_kg': 80},
              deviceId: 'device-2',
              clientTs: DateTime.utc(2026, 1, 1),
            ),
          ],
          nextCursor: 1,
        ),
        PullPage(
          ops: [
            PulledOp(
              serverSeq: 2,
              clientOpId: 'remote-2',
              entityType: 'weight_entry',
              entityId: 'e1',
              opType: 'update',
              payload: const {'weight_kg': 79},
              deviceId: 'device-2',
              clientTs: DateTime.utc(2026, 1, 2),
            ),
          ],
          nextCursor: 2,
        ),
        const PullPage(ops: [], nextCursor: 2),
      ]);

      await engine.pull();

      expect(api.pullCalls, 3);
      expect(fakeEntity.projection['e1'], {'weight_kg': 79});
      expect(await cursorStore.read(), 2);
    });

    test('resumes from the persisted cursor on the next call', () async {
      await cursorStore.write(10);
      api.pullPages.add(const PullPage(ops: [], nextCursor: 10));

      await engine.pull();

      expect(api.pullCalls, 1);
    });
  });

  test('sync pushes before it pulls', () async {
    final clientOpId = await opWriter.write(
      entityType: 'weight_entry',
      entityId: 'e1',
      opType: OpType.create,
      payload: '{"weight_kg": 80}',
    );
    api.onPush = (ops) => [PushOpResult(clientOpId: clientOpId, serverSeq: 1)];
    api.pullPages.add(const PullPage(ops: [], nextCursor: 0));

    await engine.sync();

    expect(api.lastPushed, isNotNull);
    expect(api.pullCalls, 1);
  });
}
