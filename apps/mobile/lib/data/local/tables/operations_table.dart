import 'package:drift/drift.dart';

/// Mirrors the server `operations` table shape (see
/// `services/api/src/app/models/operation.py`), plus a local-only `synced`
/// flag. `client_op_id` is the local primary key since it's generated
/// on-device before a push ever happens; `server_seq` and `server_ts` stay
/// null until the server assigns them.
class Operations extends Table {
  TextColumn get clientOpId => text()();
  IntColumn get serverSeq => integer().nullable()();
  TextColumn get userId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get opType => text()();
  TextColumn get payload => text()();
  TextColumn get deviceId => text()();
  DateTimeColumn get clientTs => dateTime()();
  DateTimeColumn get serverTs => dateTime().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {clientOpId};
}
