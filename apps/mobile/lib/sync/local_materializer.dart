import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/local/app_database.dart';
import '../domain/op_type.dart';
import 'entity_registry.dart';

class MaterializationError implements Exception {
  MaterializationError(this.message);

  final String message;

  @override
  String toString() => 'MaterializationError: $message';
}

/// Applies one op to its entity's Drift projection table. The only code
/// path allowed to write to projection tables — mirrors the server's
/// `materialize_op` (`services/api/src/app/sync/materializer.py`), including
/// field-level last-write-wins, so a device converges on the same state
/// regardless of the order it applies ops in.
///
/// Unlike the server, `create` and `update` both upsert: a device can pull
/// an update for an entity it hasn't seen the `create` op for yet (e.g.
/// during a bootstrap catch-up), and that must not be an error.
class LocalMaterializer {
  LocalMaterializer(this._db, this._registry);

  final AppDatabase _db;
  final EntityRegistry _registry;

  Future<void> materialize(Operation op) {
    final materializer = _registry[op.entityType];
    if (materializer == null) {
      throw MaterializationError(
        'No projection materializer registered for entity_type '
        '"${op.entityType}".',
      );
    }

    return _db.transaction(() async {
      if (op.opType == OpType.delete.name) {
        final deletedAt = op.serverTs ?? op.clientTs;
        final resolved = await _resolveFields(op, {'deleted_at': deletedAt});
        if (resolved.containsKey('deleted_at')) {
          await materializer.applyDelete(
            entityId: op.entityId,
            deletedAt: deletedAt,
          );
        }
        return;
      }

      final payload = jsonDecode(op.payload) as Map<String, dynamic>;
      final resolved = await _resolveFields(op, payload);
      if (resolved.isNotEmpty) {
        await materializer.applyCreateOrUpdate(
          entityId: op.entityId,
          userId: op.userId,
          fields: resolved,
        );
      }
    });
  }

  /// Returns only the fields from [payload] whose write actually wins
  /// field-level last-write-wins against whatever previously won that
  /// field, recording the new winner as a side effect.
  Future<Map<String, dynamic>> _resolveFields(
    Operation op,
    Map<String, dynamic> payload,
  ) async {
    final resolved = <String, dynamic>{};
    for (final entry in payload.entries) {
      if (await _fieldWins(op, entry.key)) {
        resolved[entry.key] = entry.value;
      }
    }
    return resolved;
  }

  Future<bool> _fieldWins(Operation op, String fieldName) async {
    final query = _db.select(_db.entityFieldVersions)
      ..where(
        (t) => t.entityId.equals(op.entityId) & t.fieldName.equals(fieldName),
      );
    final current = await query.getSingleOrNull();

    if (current != null && !_opWins(op, current)) {
      return false;
    }

    await _db
        .into(_db.entityFieldVersions)
        .insertOnConflictUpdate(
          EntityFieldVersionsCompanion.insert(
            entityId: op.entityId,
            fieldName: fieldName,
            userId: op.userId,
            clientTs: op.clientTs,
            serverSeq: Value(op.serverSeq),
          ),
        );
    return true;
  }

  /// The op with the later `client_ts` wins; on a tie, whichever was
  /// actually ingested later (`server_seq`) wins. A null `server_seq` means
  /// "not yet confirmed by the server" — treated as newest, since it's an
  /// optimistic write of this device's own most recent edit.
  bool _opWins(Operation op, EntityFieldVersion current) {
    if (op.clientTs != current.clientTs) {
      return op.clientTs.isAfter(current.clientTs);
    }
    if (op.serverSeq == null) return true;
    if (current.serverSeq == null) return false;
    return op.serverSeq! > current.serverSeq!;
  }
}
