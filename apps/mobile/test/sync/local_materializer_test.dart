import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/local/app_database.dart';
import 'package:healthtrack/domain/op_type.dart';
import 'package:healthtrack/sync/entity_materializer.dart';
import 'package:healthtrack/sync/entity_registry.dart';
import 'package:healthtrack/sync/local_materializer.dart';

class _RecordedWrite {
  _RecordedWrite.upsert(this.entityId, this.fields) : deletedAt = null;
  _RecordedWrite.delete(this.entityId, DateTime this.deletedAt)
    : fields = const {};

  final String entityId;
  final Map<String, dynamic> fields;
  final DateTime? deletedAt;
}

class _FakeEntityMaterializer implements EntityMaterializer {
  final writes = <_RecordedWrite>[];
  final Map<String, Map<String, dynamic>> projection = {};

  @override
  Future<void> applyCreateOrUpdate({
    required String entityId,
    required String userId,
    required Map<String, dynamic> fields,
  }) async {
    writes.add(_RecordedWrite.upsert(entityId, fields));
    projection.putIfAbsent(entityId, () => {}).addAll(fields);
  }

  @override
  Future<void> applyDelete({
    required String entityId,
    required DateTime deletedAt,
  }) async {
    writes.add(_RecordedWrite.delete(entityId, deletedAt));
    projection.putIfAbsent(entityId, () => {})['deleted_at'] = deletedAt;
  }
}

Operation _op({
  required String clientOpId,
  required String entityId,
  required OpType opType,
  required Map<String, dynamic> payload,
  required DateTime clientTs,
  int? serverSeq,
  DateTime? serverTs,
}) {
  return Operation(
    clientOpId: clientOpId,
    serverSeq: serverSeq,
    userId: 'user-1',
    entityType: 'weight_entry',
    entityId: entityId,
    opType: opType.name,
    payload: jsonEncode(payload),
    deviceId: 'device-1',
    clientTs: clientTs,
    serverTs: serverTs,
    synced: serverSeq != null,
  );
}

void main() {
  late AppDatabase db;
  late EntityRegistry registry;
  late _FakeEntityMaterializer fake;
  late LocalMaterializer materializer;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    registry = EntityRegistry();
    fake = _FakeEntityMaterializer();
    registry.register('weight_entry', fake);
    materializer = LocalMaterializer(db, registry);
  });

  tearDown(() => db.close());

  test('throws when no materializer is registered for the entity type', () {
    final op = _op(
      clientOpId: 'op-1',
      entityId: 'e1',
      opType: OpType.create,
      payload: const {'weight_kg': 80},
      clientTs: DateTime.utc(2026, 1, 1),
    ).copyWith(entityType: 'unknown_entity');

    expect(
      () => materializer.materialize(op),
      throwsA(isA<MaterializationError>()),
    );
  });

  test('applies a create by upserting every payload field', () async {
    final op = _op(
      clientOpId: 'op-1',
      entityId: 'e1',
      opType: OpType.create,
      payload: const {'weight_kg': 80, 'note': 'morning'},
      clientTs: DateTime.utc(2026, 1, 1),
    );

    await materializer.materialize(op);

    expect(fake.projection['e1'], {'weight_kg': 80, 'note': 'morning'});
  });

  test(
    'a later client_ts wins over an earlier one for the same field',
    () async {
      final earlier = _op(
        clientOpId: 'op-1',
        entityId: 'e1',
        opType: OpType.create,
        payload: const {'weight_kg': 80},
        clientTs: DateTime.utc(2026, 1, 1, 8),
      );
      final later = _op(
        clientOpId: 'op-2',
        entityId: 'e1',
        opType: OpType.update,
        payload: const {'weight_kg': 79},
        clientTs: DateTime.utc(2026, 1, 1, 9),
      );

      // Applied out of order — later op materialized first.
      await materializer.materialize(later);
      await materializer.materialize(earlier);

      expect(fake.projection['e1'], {'weight_kg': 79});
    },
  );

  test('on a client_ts tie, the higher server_seq wins', () async {
    final sameTs = DateTime.utc(2026, 1, 1);
    final lowSeq = _op(
      clientOpId: 'op-1',
      entityId: 'e1',
      opType: OpType.create,
      payload: const {'weight_kg': 80},
      clientTs: sameTs,
      serverSeq: 5,
    );
    final highSeq = _op(
      clientOpId: 'op-2',
      entityId: 'e1',
      opType: OpType.update,
      payload: const {'weight_kg': 79},
      clientTs: sameTs,
      serverSeq: 6,
    );

    await materializer.materialize(lowSeq);
    await materializer.materialize(highSeq);
    // Re-applying the lower server_seq op again must not overwrite the winner.
    await materializer.materialize(lowSeq);

    expect(fake.projection['e1'], {'weight_kg': 79});
  });

  test('an unsynced (null server_seq) write beats a synced one at the same client_ts', () async {
    final sameTs = DateTime.utc(2026, 1, 1);
    final synced = _op(
      clientOpId: 'op-1',
      entityId: 'e1',
      opType: OpType.create,
      payload: const {'weight_kg': 80},
      clientTs: sameTs,
      serverSeq: 5,
    );
    final optimisticLocal = _op(
      clientOpId: 'op-2',
      entityId: 'e1',
      opType: OpType.update,
      payload: const {'weight_kg': 79},
      clientTs: sameTs,
    );

    await materializer.materialize(synced);
    await materializer.materialize(optimisticLocal);

    expect(fake.projection['e1'], {'weight_kg': 79});
  });

  test(
    'delete applies a tombstone via applyDelete, not a hard delete',
    () async {
      final deletedAt = DateTime.utc(2026, 1, 2);
      final op = _op(
        clientOpId: 'op-1',
        entityId: 'e1',
        opType: OpType.delete,
        payload: const {},
        clientTs: DateTime.utc(2026, 1, 1),
        serverTs: deletedAt,
      );

      await materializer.materialize(op);

      expect(fake.writes.single.deletedAt, deletedAt);
    },
  );
}
