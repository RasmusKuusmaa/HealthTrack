import 'package:drift/drift.dart';

import '../../data/local/app_database.dart';
import '../../sync/entity_materializer.dart';

/// Applies `user_profile` ops (and bootstrap rows) to the local
/// [UserProfiles] projection. Registered under entity_type `user_profile`.
class UserProfileMaterializer implements EntityMaterializer {
  UserProfileMaterializer(this._db);

  final AppDatabase _db;

  @override
  Future<void> applyCreateOrUpdate({
    required String entityId,
    required String userId,
    required Map<String, dynamic> fields,
  }) async {
    final companion = UserProfilesCompanion(
      id: Value(entityId),
      userId: Value(userId),
      displayName: _stringOrAbsent(fields, 'display_name'),
      birthDate: _dateOrAbsent(fields, 'birth_date'),
      sexAtBirth: _stringOrAbsent(fields, 'sex_at_birth'),
      heightCm: _doubleOrAbsent(fields, 'height_cm'),
      timezone: _nonNullStringOrAbsent(fields, 'timezone'),
      locale: _nonNullStringOrAbsent(fields, 'locale'),
      unitSystem: _nonNullStringOrAbsent(fields, 'unit_system'),
    );
    await _db.into(_db.userProfiles).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> applyDelete({
    required String entityId,
    required DateTime deletedAt,
  }) async {
    await (_db.update(_db.userProfiles)..where((t) => t.id.equals(entityId)))
        .write(UserProfilesCompanion(deletedAt: Value(deletedAt)));
  }

  Value<String?> _stringOrAbsent(Map<String, dynamic> fields, String key) {
    if (!fields.containsKey(key)) return const Value.absent();
    return Value(fields[key] as String?);
  }

  /// For columns with a SQL default (`timezone`, `locale`, `unit_system`):
  /// trusts the payload never sends an explicit null for these, since doing
  /// so would violate the server's own NOT NULL constraint on them.
  Value<String> _nonNullStringOrAbsent(
    Map<String, dynamic> fields,
    String key,
  ) {
    if (!fields.containsKey(key)) return const Value.absent();
    return Value(fields[key] as String);
  }

  Value<double?> _doubleOrAbsent(Map<String, dynamic> fields, String key) {
    if (!fields.containsKey(key)) return const Value.absent();
    return Value((fields[key] as num?)?.toDouble());
  }

  /// [birth_date] is a plain calendar date, not an instant — parsing it
  /// with plain [DateTime.parse] would interpret a bare "YYYY-MM-DD" string
  /// as local midnight, which then round-trips through UTC storage as a
  /// different day depending on the device's timezone. Rebuilding the date
  /// fields as UTC keeps it the same calendar date everywhere.
  Value<DateTime?> _dateOrAbsent(Map<String, dynamic> fields, String key) {
    if (!fields.containsKey(key)) return const Value.absent();
    final raw = fields[key] as String?;
    if (raw == null) return const Value(null);
    final parsed = DateTime.parse(raw);
    return Value(DateTime.utc(parsed.year, parsed.month, parsed.day));
  }
}
