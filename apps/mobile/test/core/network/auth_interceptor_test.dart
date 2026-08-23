import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/core/network/auth_interceptor.dart';
import 'package:healthtrack/data/secure/secure_key_value_store.dart';
import 'package:healthtrack/data/secure/token_store.dart';

class _FakeSecureKeyValueStore implements SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// Serves canned responses keyed by call count for the /protected path:
/// 401 while [failUntilCall] hasn't been reached, 200 afterward. Records
/// every request's Authorization header.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter({this.failUntilCall = 0});

  final int failUntilCall;
  int callCount = 0;
  final authHeaders = <String?>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    authHeaders.add(options.headers['Authorization'] as String?);

    if (options.path == '/auth/refresh') {
      return ResponseBody.fromString(
        '{"access_token":"new-access","refresh_token":"new-refresh"}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    callCount++;
    if (callCount <= failUntilCall) {
      return ResponseBody.fromString('{"detail":"unauthorized"}', 401);
    }
    return ResponseBody.fromString('{"ok":true}', 200);
  }
}

void main() {
  test('attaches the stored access token as a bearer header', () async {
    final storage = _FakeSecureKeyValueStore();
    final tokenStore = TokenStore(storage);
    await tokenStore.save(accessToken: 'access-1', refreshToken: 'refresh-1');
    final adapter = _ScriptedAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(
          dio: Dio(),
          tokenStore: tokenStore,
          deviceId: 'device-1',
          refreshTokens: (refreshToken, deviceId) async => null,
        ),
      );

    await dio.get<void>('/protected');

    expect(adapter.authHeaders.single, 'Bearer access-1');
  });

  test(
    'refreshes once on a 401 and retries with the new access token',
    () async {
      final storage = _FakeSecureKeyValueStore();
      final tokenStore = TokenStore(storage);
      await tokenStore.save(accessToken: 'expired', refreshToken: 'refresh-1');
      final adapter = _ScriptedAdapter(failUntilCall: 1);
      var refreshCalls = 0;

      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          tokenStore: tokenStore,
          deviceId: 'device-1',
          refreshTokens: (refreshToken, deviceId) async {
            refreshCalls++;
            expect(refreshToken, 'refresh-1');
            expect(deviceId, 'device-1');
            return const TokenPair(
              accessToken: 'new-access',
              refreshToken: 'new-refresh',
            );
          },
        ),
      );

      final response = await dio.get<dynamic>('/protected');

      expect(response.statusCode, 200);
      expect(refreshCalls, 1);
      expect(await tokenStore.readAccessToken(), 'new-access');
      expect(await tokenStore.readRefreshToken(), 'new-refresh');
      expect(adapter.authHeaders.last, 'Bearer new-access');
    },
  );

  test('clears tokens and reports failure when refresh itself fails', () async {
    final storage = _FakeSecureKeyValueStore();
    final tokenStore = TokenStore(storage);
    await tokenStore.save(accessToken: 'expired', refreshToken: 'refresh-1');
    final adapter = _ScriptedAdapter(failUntilCall: 999);
    var signedOut = false;

    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenStore: tokenStore,
        deviceId: 'device-1',
        refreshTokens: (refreshToken, deviceId) async => null,
        onRefreshFailed: () => signedOut = true,
      ),
    );

    await expectLater(
      dio.get<void>('/protected'),
      throwsA(isA<DioException>()),
    );

    expect(signedOut, isTrue);
    expect(await tokenStore.readAccessToken(), isNull);
    expect(await tokenStore.readRefreshToken(), isNull);
  });

  test(
    'does not retry a second time if the retried request also 401s',
    () async {
      final storage = _FakeSecureKeyValueStore();
      final tokenStore = TokenStore(storage);
      await tokenStore.save(accessToken: 'expired', refreshToken: 'refresh-1');
      final adapter = _ScriptedAdapter(failUntilCall: 999);
      var refreshCalls = 0;

      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          tokenStore: tokenStore,
          deviceId: 'device-1',
          refreshTokens: (refreshToken, deviceId) async {
            refreshCalls++;
            return const TokenPair(
              accessToken: 'still-bad',
              refreshToken: 'still-bad-r',
            );
          },
        ),
      );

      await expectLater(
        dio.get<void>('/protected'),
        throwsA(isA<DioException>()),
      );

      expect(refreshCalls, 1);
      // Original attempt + the single retry, nothing more.
      expect(adapter.callCount, 2);
    },
  );

  test('coalesces concurrent 401s into a single refresh call', () async {
    final storage = _FakeSecureKeyValueStore();
    final tokenStore = TokenStore(storage);
    await tokenStore.save(accessToken: 'expired', refreshToken: 'refresh-1');
    final adapter = _ScriptedAdapter(failUntilCall: 2);
    var refreshCalls = 0;

    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenStore: tokenStore,
        deviceId: 'device-1',
        refreshTokens: (refreshToken, deviceId) async {
          refreshCalls++;
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return const TokenPair(
            accessToken: 'new-access',
            refreshToken: 'new-refresh',
          );
        },
      ),
    );

    final results = await Future.wait([
      dio.get<dynamic>('/protected'),
      dio.get<dynamic>('/protected'),
    ]);

    expect(results.every((r) => r.statusCode == 200), isTrue);
    expect(refreshCalls, 1);
  });
}
