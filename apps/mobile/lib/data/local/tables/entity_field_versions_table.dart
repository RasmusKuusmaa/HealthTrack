import 'package:drift/drift.dart';

/// Local mirror of the server's `entity_field_versions` bookkeeping (see
/// `services/api/src/app/models/entity_field_version.py`). Tracks, per
/// entity field, which op last won field-level last-write-wins — required
/// so replaying pulled ops in any order converges on the same state the
/// server has (docs/sync-protocol.md).
class EntityFieldVersions extends Table {
  TextColumn get entityId => text()();
  TextColumn get fieldName => text()();
  TextColumn get userId => text()();
  DateTimeColumn get clientTs => dateTime()();
  // Nullable unlike the server's copy: an optimistic local write is
  // materialized before it has been pushed, so it has no server_seq yet.
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {entityId, fieldName};
}
