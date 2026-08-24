import 'package:drift/drift.dart';

/// Local projection of a `weight_entry` sync entity (see
/// `services/api/src/app/sync/entities.py`). `id` is client-generated at
/// creation time, unlike `UserProfiles.id` which equals the user's own id.
class WeightEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  // Nullable locally (unlike the server's NOT NULL): an update materializing
  // before the row has ever been created locally must not hit a NOT NULL
  // constraint. UI treats null the same as "not loaded yet".
  DateTimeColumn get loggedAtUtc => dateTime().nullable()();
  DateTimeColumn get localDate => dateTime().nullable()();
  IntColumn get tzOffsetMinutes => integer().nullable()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
