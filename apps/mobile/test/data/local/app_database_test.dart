import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('inserts and reads back an unsynced operation', () async {
    await db
        .into(db.operations)
        .insert(
          OperationsCompanion.insert(
            clientOpId: 'op-1',
            userId: 'user-1',
            entityType: 'weight_entry',
            entityId: 'entity-1',
            opType: 'create',
            payload: '{}',
            deviceId: 'device-1',
            clientTs: DateTime.utc(2026, 1, 1),
          ),
        );

    final rows = await db.select(db.operations).get();

    expect(rows, hasLength(1));
    expect(rows.single.clientOpId, 'op-1');
    expect(rows.single.serverSeq, isNull);
    expect(rows.single.serverTs, isNull);
    expect(rows.single.synced, isFalse);
  });

  test('client_op_id is the primary key and rejects duplicates', () async {
    final companion = OperationsCompanion.insert(
      clientOpId: 'op-1',
      userId: 'user-1',
      entityType: 'weight_entry',
      entityId: 'entity-1',
      opType: 'create',
      payload: '{}',
      deviceId: 'device-1',
      clientTs: DateTime.utc(2026, 1, 1),
    );

    await db.into(db.operations).insert(companion);

    expect(
      () => db.into(db.operations).insert(companion),
      throwsA(anything),
    );
  });
}
