import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/local/app_database.dart';
import 'package:healthtrack/data/local/op_writer.dart';
import 'package:healthtrack/domain/op_type.dart';

void main() {
  late AppDatabase db;
  late OpWriter writer;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    writer = OpWriter(
      db,
      userId: 'user-1',
      deviceId: 'device-1',
      now: () => DateTime.utc(2026, 1, 1),
    );
  });

  tearDown(() => db.close());

  test('appends an unsynced operation and returns its client_op_id', () async {
    final clientOpId = await writer.write(
      entityType: 'weight_entry',
      entityId: 'entity-1',
      opType: OpType.create,
      payload: '{"weight_kg": 80}',
    );

    final rows = await db.select(db.operations).get();

    expect(rows, hasLength(1));
    final row = rows.single;
    expect(row.clientOpId, clientOpId);
    expect(row.userId, 'user-1');
    expect(row.deviceId, 'device-1');
    expect(row.entityType, 'weight_entry');
    expect(row.entityId, 'entity-1');
    expect(row.opType, 'create');
    expect(row.payload, '{"weight_kg": 80}');
    expect(row.clientTs, DateTime.utc(2026, 1, 1));
    expect(row.synced, isFalse);
    expect(row.serverSeq, isNull);
  });

  test('generates a unique client_op_id per write', () async {
    final first = await writer.write(
      entityType: 'weight_entry',
      entityId: 'entity-1',
      opType: OpType.create,
      payload: '{}',
    );
    final second = await writer.write(
      entityType: 'weight_entry',
      entityId: 'entity-1',
      opType: OpType.update,
      payload: '{}',
    );

    expect(first, isNot(equals(second)));
    expect(await db.select(db.operations).get(), hasLength(2));
  });
}
