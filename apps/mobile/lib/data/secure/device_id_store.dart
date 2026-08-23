import 'package:uuid/uuid.dart';

import 'secure_key_value_store.dart';

/// A stable per-install device identifier, generated once and persisted.
/// Scopes local sync ops (`OpWriter`/`SyncEngine`) and auth sessions (the
/// server's `devices` table) to this installation.
class DeviceIdStore {
  DeviceIdStore(this._storage, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  static const _key = 'device_id';

  final SecureKeyValueStore _storage;
  final Uuid _uuid;

  Future<String> read() async {
    final existing = await _storage.read(_key);
    if (existing != null) return existing;

    final generated = _uuid.v4();
    await _storage.write(_key, generated);
    return generated;
  }
}
