import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/core/network/auth_interceptor.dart';
import 'package:healthtrack/data/secure/secure_key_value_store.dart';
import 'package:healthtrack/data/secure/token_store.dart';
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

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final ResponseBody Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _handler(options);
  }
}

/// Verifies the generated `healthtrack_api_client` actually works wired
/// through this app's shared `Dio` instance and [AuthInterceptor] — not
/// just that it compiles.
void main() {
  test(
    'a generated API call carries the bearer token from TokenStore',
    () async {
      final tokenStore = TokenStore(_InMemorySecureStore());
      await tokenStore.save(accessToken: 'access-1', refreshToken: 'refresh-1');

      late RequestOptions captured;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = _FakeAdapter((options) {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode({'status': 'ok'}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        })
        ..interceptors.add(
          AuthInterceptor(
            dio: Dio(),
            tokenStore: tokenStore,
            deviceId: 'device-1',
            refreshTokens: (refreshToken, deviceId) async => null,
          ),
        );

      // An explicit empty list stops HealthtrackApiClient from tacking its
      // own default OAuth/Basic/Bearer/ApiKey interceptors onto `dio` — this
      // app only wants the AuthInterceptor already attached above.
      final client = HealthtrackApiClient(dio: dio, interceptors: const []);
      final response = await client.getHealthApi().healthHealthGet();

      expect(response.statusCode, 200);
      expect(response.data, {'status': 'ok'});
      expect(captured.path, '/health');
      expect(captured.headers['Authorization'], 'Bearer access-1');
    },
  );
}
