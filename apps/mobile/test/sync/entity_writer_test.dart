import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/local/app_database.dart';
import 'package:healthtrack/data/local/op_writer.dart';
import 'package:healthtrack/domain/op_type.dart';
import 'package:healthtrack/sync/entity_materializer.dart';
import 'package:healthtrack/sync/entity_registry.dart';
import 'package:healthtrack/sync/entity_writer.dart';
import 'package:healthtrack/sync/local_materializer.dart';

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
    projection.putIfAbsent(entityId, () => {})['deleted_at'] = deletedAt;
  }
}

void main() {
  late AppDatabase db;
  late EntityWriter writer;
  late _FakeEntityMaterializer fakeEntity;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final opWriter = OpWriter(db, userId: 'user-1', deviceId: 'device-1');
    fakeEntity = _FakeEntityMaterializer();
    final registry = EntityRegistry()..register('weight_entry', fakeEntity);
    writer = EntityWriter(db, opWriter, LocalMaterializer(db, registry));
  });

  tearDown(() => db.close());

  test('appends the op and immediately applies it to the projection', () async {
    final clientOpId = await writer.writeAndMaterialize(
      entityType: 'weight_entry',
      entityId: 'e1',
      opType: OpType.create,
      payload: '{"weight_kg": 80}',
    );

    expect(fakeEntity.projection['e1'], {'weight_kg': 80});

    final row = await (db.select(
      db.operations,
    )..where((t) => t.clientOpId.equals(clientOpId))).getSingle();
    expect(row.synced, isFalse);
    expect(row.serverSeq, isNull);
  });

  test('a second write updates fields without clobbering the rest', () async {
    await writer.writeAndMaterialize(
      entityType: 'weight_entry',
      entityId: 'e1',
      opType: OpType.create,
      payload: '{"weight_kg": 80, "note": "morning"}',
    );
    await writer.writeAndMaterialize(
      entityType: 'weight_entry',
      entityId: 'e1',
      opType: OpType.update,
      payload: '{"weight_kg": 79}',
    );

    expect(fakeEntity.projection['e1'], {'weight_kg': 79, 'note': 'morning'});
  });
}
