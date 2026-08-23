// ignore_for_file: prefer_initializing_formals
import 'package:dio/dio.dart';

import '../../data/secure/token_store.dart';

class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

typedef RefreshTokens = Future<TokenPair?> Function(
  String refreshToken,
  String deviceId,
);

/// Attaches the stored access token to every request and, on a 401,
/// refreshes it exactly once via [refreshTokens] and retries the original
/// request. Concurrent 401s share a single in-flight refresh rather than
/// each triggering their own. If refresh itself fails, clears the stored
/// tokens, calls [onRefreshFailed] (e.g. to sign the user out), and lets the
/// original 401 propagate.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenStore tokenStore,
    required String deviceId,
    required RefreshTokens refreshTokens,
    void Function()? onRefreshFailed,
  }) : _dio = dio,
       _tokenStore = tokenStore,
       _deviceId = deviceId,
       _refreshTokens = refreshTokens,
       _onRefreshFailed = onRefreshFailed;

  final Dio _dio;
  final TokenStore _tokenStore;
  final String _deviceId;
  final RefreshTokens _refreshTokens;
  final void Function()? _onRefreshFailed;

  Future<bool>? _refreshInFlight;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenStore.readAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['authRetried'] == true;

    if (!isUnauthorized || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshed = await (_refreshInFlight ??= _doRefresh().whenComplete(() {
      _refreshInFlight = null;
    }));

    if (!refreshed) {
      await _tokenStore.clear();
      _onRefreshFailed?.call();
      handler.next(err);
      return;
    }

    try {
      final accessToken = await _tokenStore.readAccessToken();
      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..extra['authRetried'] = true;
      final response = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null) return false;

    try {
      final newTokens = await _refreshTokens(refreshToken, _deviceId);
      if (newTokens == null) return false;

      await _tokenStore.save(
        accessToken: newTokens.accessToken,
        refreshToken: newTokens.refreshToken,
      );
      return true;
    } on Exception {
      return false;
    }
  }
}

/// A [RefreshTokens] implementation calling the real `POST /auth/refresh`.
/// Use a `Dio` instance that doesn't itself carry an [AuthInterceptor], so
/// refreshing never recurses through the same 401 handling.
class DioTokenRefresher {
  DioTokenRefresher(this._dio);

  final Dio _dio;

  Future<TokenPair?> call(String refreshToken, String deviceId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken, 'device_id': deviceId},
      );
      final data = response.data!;
      return TokenPair(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
    } on DioException {
      return null;
    }
  }
}
