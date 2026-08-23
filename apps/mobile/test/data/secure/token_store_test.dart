import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/secure/secure_key_value_store.dart';
import 'package:healthtrack/data/secure/token_store.dart';

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
  late TokenStore tokenStore;

  setUp(() {
    storage = _FakeSecureKeyValueStore();
    tokenStore = TokenStore(storage);
  });

  test('reads null for both tokens when nothing has been saved', () async {
    expect(await tokenStore.readAccessToken(), isNull);
    expect(await tokenStore.readRefreshToken(), isNull);
  });

  test('round-trips a saved access and refresh token', () async {
    await tokenStore.save(accessToken: 'access-1', refreshToken: 'refresh-1');

    expect(await tokenStore.readAccessToken(), 'access-1');
    expect(await tokenStore.readRefreshToken(), 'refresh-1');
  });

  test(
    'save overwrites a previously saved pair, e.g. after refresh rotation',
    () async {
      await tokenStore.save(accessToken: 'access-1', refreshToken: 'refresh-1');
      await tokenStore.save(accessToken: 'access-2', refreshToken: 'refresh-2');

      expect(await tokenStore.readAccessToken(), 'access-2');
      expect(await tokenStore.readRefreshToken(), 'refresh-2');
    },
  );

  test('clear removes both tokens', () async {
    await tokenStore.save(accessToken: 'access-1', refreshToken: 'refresh-1');
    await tokenStore.clear();

    expect(await tokenStore.readAccessToken(), isNull);
    expect(await tokenStore.readRefreshToken(), isNull);
  });
}
