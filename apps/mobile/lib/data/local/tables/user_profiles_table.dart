import 'package:drift/drift.dart';

/// Local projection of the server's `user_profiles` row for the signed-in
/// user, kept up to date by the `user_profile` sync entity (see
/// `services/api/src/app/sync/entities.py`). `id` equals the user's own id.
class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  // Nullable locally (unlike the server's NOT NULL): an update materializing
  // before the row has ever been created locally must not hit a NOT NULL
  // constraint. UI treats null the same as "not loaded yet".
  TextColumn get displayName => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get sexAtBirth => text().nullable()();
  RealColumn get heightCm => real().nullable()();
  TextColumn get timezone => text().withDefault(const Constant('UTC'))();
  TextColumn get locale => text().withDefault(const Constant('en'))();
  TextColumn get unitSystem => text().withDefault(const Constant('metric'))();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
