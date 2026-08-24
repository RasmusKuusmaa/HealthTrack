// ignore_for_file: prefer_initializing_formals
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/app_database.dart';
import '../../domain/op_type.dart';
import '../../sync/entity_writer.dart';

/// Reads and edits the signed-in user's weight entries — the local
/// `weight_entries` projection, kept up to date by the `weight_entry` sync
/// entity. Unlike the user profile (a singleton per user), a user has many
/// weight entries, each identified by a client-generated id.
class WeightRepository {
  WeightRepository({
    required AppDatabase db,
    required EntityWriter entityWriter,
    required String userId,
    Uuid? uuid,
  }) : _db = db,
       _entityWriter = entityWriter,
       _userId = userId,
       _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final EntityWriter _entityWriter;
  final String _userId;
  final Uuid _uuid;

  /// All non-deleted entries for the signed-in user, newest first.
  Stream<List<WeightEntry>> watchAll() {
    return (_db.select(_db.weightEntries)
          ..where((t) => t.userId.equals(_userId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.localDate)]))
        .watch();
  }

  /// Creates a new weight entry and returns its (client-generated) id.
  Future<String> create(Map<String, dynamic> fields) async {
    final entityId = _uuid.v4();
    await _entityWriter.writeAndMaterialize(
      entityType: 'weight_entry',
      entityId: entityId,
      opType: OpType.create,
      payload: jsonEncode(fields),
    );
    return entityId;
  }

  /// Writes only the given fields — a field-level partial update, per the
  /// op log's payload convention.
  Future<void> update(String entityId, Map<String, dynamic> fields) async {
    await _entityWriter.writeAndMaterialize(
      entityType: 'weight_entry',
      entityId: entityId,
      opType: OpType.update,
      payload: jsonEncode(fields),
    );
  }

  Future<void> delete(String entityId) async {
    await _entityWriter.writeAndMaterialize(
      entityType: 'weight_entry',
      entityId: entityId,
      opType: OpType.delete,
      payload: jsonEncode(<String, dynamic>{}),
    );
  }
}
