import 'package:drift/drift.dart';

import '../../data/local/app_database.dart';
import '../../sync/entity_materializer.dart';

/// Applies `weight_entry` ops (and bootstrap rows) to the local
/// [WeightEntries] projection. Registered under entity_type `weight_entry`.
class WeightEntryMaterializer implements EntityMaterializer {
  WeightEntryMaterializer(this._db);

  final AppDatabase _db;

  @override
  Future<void> applyCreateOrUpdate({
    required String entityId,
    required String userId,
    required Map<String, dynamic> fields,
  }) async {
    final companion = WeightEntriesCompanion(
      id: Value(entityId),
      userId: Value(userId),
      loggedAtUtc: _instantOrAbsent(fields, 'logged_at_utc'),
      localDate: _dateOrAbsent(fields, 'local_date'),
      tzOffsetMinutes: _intOrAbsent(fields, 'tz_offset_minutes'),
      weightKg: _doubleOrAbsent(fields, 'weight_kg'),
      source: _nonNullStringOrAbsent(fields, 'source'),
      note: _stringOrAbsent(fields, 'note'),
    );
    await _db.into(_db.weightEntries).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> applyDelete({
    required String entityId,
    required DateTime deletedAt,
  }) async {
    await (_db.update(_db.weightEntries)..where((t) => t.id.equals(entityId)))
        .write(WeightEntriesCompanion(deletedAt: Value(deletedAt)));
  }

  Value<String?> _stringOrAbsent(Map<String, dynamic> fields, String key) {
    if (!fields.containsKey(key)) return const Value.absent();
    return Value(fields[key] as String?);
  }

  /// For columns with a SQL default (`source`): trusts the payload never
  /// sends an explicit null for it, since doing so would violate the
  /// server's own NOT NULL constraint on it.
  Value<String> _nonNullStringOrAbsent(
    Map<String, dynamic> fields,
    String key,
  ) {
    if (!fields.containsKey(key)) return const Value.absent();
    return Value(fields[key] as String);
  }

  Value<int?> _intOrAbsent(Map<String, dynamic> fields, String key) {
    if (!fields.containsKey(key)) return const Value.absent();
    return Value((fields[key] as num?)?.toInt());
  }

  Value<double?> _doubleOrAbsent(Map<String, dynamic> fields, String key) {
    if (!fields.containsKey(key)) return const Value.absent();
    return Value((fields[key] as num?)?.toDouble());
  }

  /// [local_date] is a plain calendar date, not an instant — parsing it
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

  /// [logged_at_utc] is a real instant, so unlike [local_date] it's parsed
  /// as-is: `DateTime.parse` on a UTC-offset ISO string already yields the
  /// correct instant.
  Value<DateTime?> _instantOrAbsent(Map<String, dynamic> fields, String key) {
    if (!fields.containsKey(key)) return const Value.absent();
    final raw = fields[key] as String?;
    if (raw == null) return const Value(null);
    return Value(DateTime.parse(raw));
  }
}
