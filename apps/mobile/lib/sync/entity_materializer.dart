/// Implemented once per synced entity type and registered with an
/// [EntityRegistry]. [LocalMaterializer] owns field-level conflict
/// resolution; this interface only ever receives fields that have already
/// won and should be written to the entity's own Drift projection table.
abstract class EntityMaterializer {
  /// Applies a create or update: upserts [fields] onto the projection row
  /// for [entityId], creating it (scoped to [userId]) if it doesn't exist.
  Future<void> applyCreateOrUpdate({
    required String entityId,
    required String userId,
    required Map<String, dynamic> fields,
  });

  /// Applies a tombstone delete. Never hard-deletes the row.
  Future<void> applyDelete({required String entityId, required DateTime deletedAt});
}
