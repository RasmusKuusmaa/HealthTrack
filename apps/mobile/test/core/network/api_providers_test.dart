import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/core/network/api_providers.dart';
import 'package:healthtrack/data/secure/secure_key_value_store.dart';

class _InMemorySecureStore implements SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

String _fakeJwt(Map<String, dynamic> claims) {
  String segment(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${segment({'alg': 'RS256'})}.${segment(claims)}.fake-signature';
}

void main() {
  test(
    'currentUserId decodes the sub claim from the stored access token',
    () async {
      final storage = _InMemorySecureStore();
      final container = ProviderContainer(
        overrides: [secureKeyValueStoreProvider.overrideWith((ref) => storage)],
      );
      addTearDown(container.dispose);
      await container
          .read(tokenStoreProvider)
          .save(
            accessToken: _fakeJwt({'sub': 'user-42'}),
            refreshToken: 'refresh-1',
          );

      final userId = await container.read(currentUserIdProvider.future);

      expect(userId, 'user-42');
    },
  );

  test('currentUserId throws when nothing is signed in', () async {
    final container = ProviderContainer(
      overrides: [
        secureKeyValueStoreProvider.overrideWith(
          (ref) => _InMemorySecureStore(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(currentUserIdProvider.future),
      throwsA(isA<StateError>()),
    );
  });
}
