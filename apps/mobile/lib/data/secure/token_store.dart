import 'secure_key_value_store.dart';

/// Persists the current session's JWT access token and rotating refresh
/// token (see the auth decision in docs/architecture.md). The only place in
/// the app allowed to read or write these values.
class TokenStore {
  TokenStore(this._storage);

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';

  final SecureKeyValueStore _storage;

  Future<String?> readAccessToken() => _storage.read(_accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(_refreshTokenKey);

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(_accessTokenKey, accessToken);
    await _storage.write(_refreshTokenKey, refreshToken);
  }

  /// Clears both tokens — call on logout or on unrecoverable refresh failure
  /// (reuse detection revoking the whole token family server-side).
  Future<void> clear() async {
    await _storage.delete(_accessTokenKey);
    await _storage.delete(_refreshTokenKey);
  }
}
