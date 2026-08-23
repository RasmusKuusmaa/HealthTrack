import '../data/secure/secure_key_value_store.dart';

/// Persists the `since` cursor for `GET /sync/pull?since=<seq>` — the
/// highest `server_seq` this device has already pulled and materialized.
class SyncCursorStore {
  SyncCursorStore(this._storage);

  static const _key = 'sync_cursor';

  final SecureKeyValueStore _storage;

  Future<int?> read() async {
    final raw = await _storage.read(_key);
    return raw == null ? null : int.parse(raw);
  }

  Future<void> write(int cursor) => _storage.write(_key, cursor.toString());

  Future<void> clear() => _storage.delete(_key);
}
