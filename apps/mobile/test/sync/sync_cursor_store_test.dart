import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/secure/secure_key_value_store.dart';
import 'package:healthtrack/sync/sync_cursor_store.dart';

class _FakeSecureKeyValueStore implements SecureKeyValueStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

void main() {
  late _FakeSecureKeyValueStore storage;
  late SyncCursorStore cursorStore;

  setUp(() {
    storage = _FakeSecureKeyValueStore();
    cursorStore = SyncCursorStore(storage);
  });

  test('reads null when nothing has been persisted yet', () async {
    expect(await cursorStore.read(), isNull);
  });

  test('round-trips a written cursor value', () async {
    await cursorStore.write(42);
    expect(await cursorStore.read(), 42);
  });

  test('overwrites a previously persisted cursor', () async {
    await cursorStore.write(1);
    await cursorStore.write(2);
    expect(await cursorStore.read(), 2);
  });

  test('clear removes the persisted cursor', () async {
    await cursorStore.write(5);
    await cursorStore.clear();
    expect(await cursorStore.read(), isNull);
  });
}
