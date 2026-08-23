import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/local/app_database.dart';
import 'package:healthtrack/data/local/op_writer.dart';
import 'package:healthtrack/data/secure/secure_key_value_store.dart';
import 'package:healthtrack/domain/op_type.dart';
import 'package:healthtrack/sync/entity_materializer.dart';
import 'package:healthtrack/sync/entity_registry.dart';
import 'package:healthtrack/sync/entity_writer.dart';
import 'package:healthtrack/sync/local_materializer.dart';
import 'package:healthtrack/sync/sync_api.dart';
import 'package:healthtrack/sync/sync_cursor_store.dart';
import 'package:healthtrack/sync/sync_engine.dart';

/// A minimal in-memory stand-in for the real `/sync/*` endpoints: assigns
/// server_seq on push and serves everything after `since` on pull — just
/// enough behavior for two [SyncEngine]s to actually converge through it.
class _FakeServer {
  final _ops = <PulledOp>[];
  int _nextSeq = 1;

  List<PushOpResult> push(List<PushOpRequest> ops) {
    final results = <PushOpResult>[];
    for (final op in ops) {
      final seq = _nextSeq++;
      _ops.add(
        PulledOp(
          serverSeq: seq,
          clientOpId: op.clientOpId,
          entityType: op.entityType,
          entityId: op.entityId,
          opType: op.opType,
          payload: op.payload,
          deviceId: op.deviceId,
          clientTs: op.clientTs,
        ),
      );
      results.add(PushOpResult(clientOpId: op.clientOpId, serverSeq: seq));
    }
    return results;
  }

  PullPage pull({required int since, int? limit}) {
    final matching = _ops.where((op) => op.serverSeq > since).toList();
    final page = limit == null ? matching : matching.take(limit).toList();
    return PullPage(
      ops: page,
      nextCursor: page.isEmpty ? since : page.last.serverSeq,
    );
  }
}

class _ServerBackedSyncApi implements SyncApi {
  _ServerBackedSyncApi(this._server);

  final _FakeServer _server;

  @override
  Future<List<PushOpResult>> push(List<PushOpRequest> ops) async =>
      _server.push(ops);

  @override
  Future<PullPage> pull({required int since, int? limit}) async =>
      _server.pull(since: since, limit: limit);

  @override
  Future<BootstrapSnapshot> bootstrap() async {
    throw UnimplementedError('not exercised by this test');
  }
}

class _RecordingMaterializer implements EntityMaterializer {
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
    projection.putIfAbsent(entityId, () => {})['deleted_at'] = deletedAt;
  }
}

class _Device {
  _Device(this.deviceId, _FakeServer server)
    : materializer = _RecordingMaterializer() {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final registry = EntityRegistry()..register('weight_entry', materializer);
    final localMaterializer = LocalMaterializer(db, registry);
    opWriter = OpWriter(db, userId: 'user-1', deviceId: deviceId);
    entityWriter = EntityWriter(db, opWriter, localMaterializer);
    syncEngine = SyncEngine(
      db: db,
      api: _ServerBackedSyncApi(server),
      cursorStore: SyncCursorStore(_InMemorySecureStore()),
      materializer: localMaterializer,
      registry: registry,
      userId: 'user-1',
    );
  }

  final String deviceId;
  final _RecordingMaterializer materializer;
  late final OpWriter opWriter;
  late final EntityWriter entityWriter;
  late final SyncEngine syncEngine;
}

class _InMemorySecureStore implements SecureKeyValueStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

void main() {
  test(
    'a write on one device reaches another device via push then pull',
    () async {
      final server = _FakeServer();
      final deviceA = _Device('device-a', server);
      final deviceB = _Device('device-b', server);

      await deviceA.entityWriter.writeAndMaterialize(
        entityType: 'weight_entry',
        entityId: 'e1',
        opType: OpType.create,
        payload: '{"weight_kg": 80}',
      );
      await deviceA.syncEngine.push();

      await deviceB.syncEngine.pull();

      expect(deviceA.materializer.projection['e1'], {'weight_kg': 80});
      expect(deviceB.materializer.projection['e1'], {'weight_kg': 80});
    },
  );

  test('concurrent edits on two devices converge to the same field value via last-write-wins', () async {
    final server = _FakeServer();
    final deviceA = _Device('device-a', server);
    final deviceB = _Device('device-b', server);

    await deviceA.entityWriter.writeAndMaterialize(
      entityType: 'weight_entry',
      entityId: 'e1',
      opType: OpType.create,
      payload: '{"weight_kg": 80}',
    );
    await deviceA.syncEngine.push();
    await deviceB.syncEngine.pull();
    expect(deviceB.materializer.projection['e1'], {'weight_kg': 80});

    // Both devices edit the same entity before either has seen the
    // other's change.
    await deviceA.entityWriter.writeAndMaterialize(
      entityType: 'weight_entry',
      entityId: 'e1',
      opType: OpType.update,
      payload: '{"weight_kg": 81}',
    );
    await deviceB.entityWriter.writeAndMaterialize(
      entityType: 'weight_entry',
      entityId: 'e1',
      opType: OpType.update,
      payload: '{"weight_kg": 79}',
    );

    // A pushes first; B's write — with a later client_ts, since it ran
    // after A's — pushes and pulls after.
    await deviceA.syncEngine.sync();
    await deviceB.syncEngine.sync();
    await deviceA.syncEngine.pull();

    // Both devices converge on B's value: the later client_ts wins,
    // regardless of push order.
    expect(deviceA.materializer.projection['e1']!['weight_kg'], 79);
    expect(deviceB.materializer.projection['e1']!['weight_kg'], 79);
  });

  test(
    'a device catches up on ops it missed across multiple pull pages',
    () async {
      final server = _FakeServer();
      final deviceA = _Device('device-a', server);
      final deviceB = _Device('device-b', server);

      for (var i = 0; i < 5; i++) {
        await deviceA.entityWriter.writeAndMaterialize(
          entityType: 'weight_entry',
          entityId: 'e$i',
          opType: OpType.create,
          payload: '{"weight_kg": ${80 + i}}',
        );
      }
      await deviceA.syncEngine.push();

      await deviceB.syncEngine.pull();

      for (var i = 0; i < 5; i++) {
        expect(deviceB.materializer.projection['e$i'], {'weight_kg': 80 + i});
      }
    },
  );
}
