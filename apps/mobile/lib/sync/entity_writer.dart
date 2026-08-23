import '../data/local/app_database.dart';
import '../data/local/op_writer.dart';
import '../domain/op_type.dart';
import 'local_materializer.dart';

/// Combines [OpWriter] and [LocalMaterializer]: appends the op to the local
/// log, then immediately applies it to the projection table, so a local
/// write shows up right away instead of waiting for a server round-trip
/// (which is what pull() would otherwise be needed for).
class EntityWriter {
  EntityWriter(this._db, this._opWriter, this._materializer);

  final AppDatabase _db;
  final OpWriter _opWriter;
  final LocalMaterializer _materializer;

  Future<String> writeAndMaterialize({
    required String entityType,
    required String entityId,
    required OpType opType,
    required String payload,
  }) async {
    final clientOpId = await _opWriter.write(
      entityType: entityType,
      entityId: entityId,
      opType: opType,
      payload: payload,
    );

    final op = await (_db.select(
      _db.operations,
    )..where((t) => t.clientOpId.equals(clientOpId))).getSingle();
    await _materializer.materialize(op);

    return clientOpId;
  }
}
