import 'package:uuid/uuid.dart';

import '../../domain/op_type.dart';
import 'app_database.dart';

/// The only permitted path for mutating local state. Feature code never
/// writes to a projection table directly — it appends an operation here,
/// which is later applied by the local materializer and pushed to the
/// server by the sync engine.
class OpWriter {
  OpWriter(
    this._db, {
    required this.userId,
    required this.deviceId,
    Uuid? uuid,
    DateTime Function()? now,
  }) : _uuid = uuid ?? const Uuid(),
       _now = now ?? DateTime.now;

  final AppDatabase _db;
  final String userId;
  final String deviceId;
  final Uuid _uuid;
  final DateTime Function() _now;

  /// Appends a new, unsynced operation to the local operation log and
  /// returns its `client_op_id`.
  Future<String> write({
    required String entityType,
    required String entityId,
    required OpType opType,
    required String payload,
  }) async {
    final clientOpId = _uuid.v4();
    await _db
        .into(_db.operations)
        .insert(
          OperationsCompanion.insert(
            clientOpId: clientOpId,
            userId: userId,
            entityType: entityType,
            entityId: entityId,
            opType: opType.name,
            payload: payload,
            deviceId: deviceId,
            clientTs: _now().toUtc(),
          ),
        );
    return clientOpId;
  }
}
