// Named parameters below use public names (db, api, ...) rather than the
// private field names they're stored in, so `prefer_initializing_formals`
// doesn't apply.
// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/local/app_database.dart';
import 'local_materializer.dart';
import 'sync_api.dart';
import 'sync_cursor_store.dart';

/// Pushes unsynced local ops and pulls new remote ops, materializing each
/// pulled op locally. Retries, backoff, and triggers (foreground,
/// connectivity, timer) are layered on top of this by later tasks — this
/// class only knows how to do one push-then-pull cycle and surface errors.
class SyncEngine {
  SyncEngine({
    required AppDatabase db,
    required SyncApi api,
    required SyncCursorStore cursorStore,
    required LocalMaterializer materializer,
    required String userId,
    int pullPageLimit = 200,
  }) : _db = db,
       _api = api,
       _cursorStore = cursorStore,
       _materializer = materializer,
       _userId = userId,
       _pullPageLimit = pullPageLimit;

  final AppDatabase _db;
  final SyncApi _api;
  final SyncCursorStore _cursorStore;
  final LocalMaterializer _materializer;
  final String _userId;
  final int _pullPageLimit;

  /// Pushes every unsynced local op, then pulls and materializes everything
  /// new since this device's cursor. A push failure aborts before any pull
  /// is attempted; a pull failure stops paging but keeps whatever was
  /// already pulled and materialized, since the cursor only ever advances
  /// after a page is fully materialized.
  Future<void> sync() async {
    await push();
    await pull();
  }

  /// Sends every locally unsynced op to the server and marks each one
  /// synced with its assigned `server_seq`. Ops are sent in `client_ts`
  /// order as an approximation of the order they were created in — the
  /// only ordering available without a dedicated local sequence column.
  Future<void> push() async {
    final unsynced =
        await (_db.select(_db.operations)
              ..where((t) => t.synced.equals(false))
              ..orderBy([(t) => OrderingTerm.asc(t.clientTs)]))
            .get();

    if (unsynced.isEmpty) return;

    final results = await _api.push(
      unsynced
          .map(
            (op) => PushOpRequest(
              clientOpId: op.clientOpId,
              entityType: op.entityType,
              entityId: op.entityId,
              opType: op.opType,
              payload: jsonDecode(op.payload) as Map<String, dynamic>,
              deviceId: op.deviceId,
              clientTs: op.clientTs,
            ),
          )
          .toList(),
    );

    for (final result in results) {
      await (_db.update(
        _db.operations,
      )..where((t) => t.clientOpId.equals(result.clientOpId))).write(
        OperationsCompanion(
          serverSeq: Value(result.serverSeq),
          synced: const Value(true),
        ),
      );
    }
  }

  /// Pages through `GET /sync/pull` from this device's persisted cursor,
  /// persisting and materializing each op before advancing the cursor —
  /// so a failure mid-page can safely resume from the last completed page.
  Future<void> pull() async {
    var cursor = await _cursorStore.read() ?? 0;

    while (true) {
      final page = await _api.pull(since: cursor, limit: _pullPageLimit);
      if (page.ops.isEmpty) break;

      for (final pulled in page.ops) {
        final op = Operation(
          clientOpId: pulled.clientOpId,
          serverSeq: pulled.serverSeq,
          userId: _userId,
          entityType: pulled.entityType,
          entityId: pulled.entityId,
          opType: pulled.opType,
          payload: jsonEncode(pulled.payload),
          deviceId: pulled.deviceId,
          clientTs: pulled.clientTs,
          serverTs: null,
          synced: true,
        );

        await _db
            .into(_db.operations)
            .insertOnConflictUpdate(op.toCompanion(true));
        await _materializer.materialize(op);
      }

      cursor = page.nextCursor;
      await _cursorStore.write(cursor);
    }
  }
}
