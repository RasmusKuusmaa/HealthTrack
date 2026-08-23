import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/secure/secure_key_value_store.dart';
import 'package:healthtrack/data/secure/token_store.dart';
import 'package:healthtrack/features/auth/auth_repository.dart';
import 'package:healthtrack_api_client/healthtrack_api_client.dart';

class _InMemorySecureStore implements SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._responses);

  final Map<String, ResponseBody Function(RequestOptions options)> _responses;
  final requests = <RequestOptions>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final handler = _responses[options.path];
    if (handler == null) {
      throw StateError('No scripted response for ${options.path}');
    }
    return handler(options);
  }
}

ResponseBody _json(int statusCode, Object body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  late _InMemorySecureStore storage;
  late TokenStore tokenStore;

  setUp(() {
    storage = _InMemorySecureStore();
    tokenStore = TokenStore(storage);
  });

  AuthRepository buildRepository(
    Map<String, ResponseBody Function(RequestOptions)> responses,
  ) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = _ScriptedAdapter(responses);
    return AuthRepository(
      dio: dio,
      authApi: AuthApi(dio),
      tokenStore: tokenStore,
      deviceId: 'device-1',
    );
  }

  test('register posts the request and returns the created user', () async {
    final repository = buildRepository({
      '/auth/register': (_) => _json(200, {
        'id': 'user-1',
        'email': 'a@example.com',
        'display_name': 'Ada',
      }),
    });

    final user = await repository.register(
      email: 'a@example.com',
      password: 'password123',
      displayName: 'Ada',
    );

    expect(user.email, 'a@example.com');
    expect(user.displayName, 'Ada');
  });

  test('login saves tokens and reports authenticated on success', () async {
    late RequestOptions captured;
    final repository = buildRepository({
      '/auth/login': (options) {
        captured = options;
        return _json(200, {
          'access_token': 'access-1',
          'refresh_token': 'refresh-1',
          'token_type': 'bearer',
          'expires_in': 900,
        });
      },
    });

    final outcome = await repository.login(
      email: 'a@example.com',
      password: 'password123',
      platform: DevicePlatform.android,
    );

    expect(outcome, LoginOutcome.authenticated);
    expect(await tokenStore.readAccessToken(), 'access-1');
    expect(await tokenStore.readRefreshToken(), 'refresh-1');

    final body = captured.data as Map<String, dynamic>;
    expect(body['device_id'], 'device-1');
    expect(body['platform'], 'android');
  });

  test('login reports mfaRequired without saving tokens when the server has no token fields', () async {
    final repository = buildRepository({
      '/auth/login': (_) => _json(200, {'mfa_required': true}),
    });

    final outcome = await repository.login(
      email: 'a@example.com',
      password: 'password123',
      platform: DevicePlatform.ios,
    );

    expect(outcome, LoginOutcome.mfaRequired);
    expect(await tokenStore.readAccessToken(), isNull);
    expect(await tokenStore.readRefreshToken(), isNull);
  });

  test('verifyEmail posts the token', () async {
    late RequestOptions captured;
    final repository = buildRepository({
      '/auth/verify-email': (options) {
        captured = options;
        return _json(200, {'verified': true});
      },
    });

    await repository.verifyEmail('verify-token');

    // Unlike the raw login() call, the generated AuthApi pre-encodes the
    // body to a JSON string before dio ever sees it.
    final body = jsonDecode(captured.data as String) as Map<String, dynamic>;
    expect(body['token'], 'verify-token');
  });
}
