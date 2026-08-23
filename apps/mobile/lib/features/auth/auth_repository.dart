// ignore_for_file: prefer_initializing_formals
import 'package:dio/dio.dart';
import 'package:healthtrack_api_client/healthtrack_api_client.dart';

import '../../data/secure/token_store.dart';

enum LoginOutcome { authenticated, mfaRequired }

/// Talks to the `/auth/*` endpoints and persists the resulting tokens. Does
/// not touch app-wide auth state (`isAuthenticatedProvider`) itself — the
/// caller updates that after a successful call, keeping this class testable
/// without Riverpod.
class AuthRepository {
  AuthRepository({
    required Dio dio,
    required AuthApi authApi,
    required TokenStore tokenStore,
    required String deviceId,
  }) : _dio = dio,
       _authApi = authApi,
       _tokenStore = tokenStore,
       _deviceId = deviceId;

  final Dio _dio;
  final AuthApi _authApi;
  final TokenStore _tokenStore;
  final String _deviceId;

  Future<UserPublic> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _authApi.registerAuthRegisterPost(
      registerRequest: RegisterRequest(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
    return response.data!;
  }

  Future<void> verifyEmail(String token) async {
    await _authApi.verifyEmailEndpointAuthVerifyEmailPost(
      verifyEmailRequest: VerifyEmailRequest(token: token),
    );
  }

  /// Bypasses the generated `loginAuthLoginPost`: its response model
  /// merges the server's `TokenPair | MfaRequiredResponse` union into one
  /// class that requires every `TokenPair` field, so it throws on an
  /// actual MFA-required response (`{"mfa_required": true}` alone, with no
  /// token fields). Posting through the raw `Dio` and reading the JSON
  /// directly avoids that.
  Future<LoginOutcome> login({
    required String email,
    required String password,
    required DevicePlatform platform,
    String deviceName = 'Unknown device',
    String? totpCode,
    String? recoveryCode,
  }) async {
    final request = LoginRequest(
      email: email,
      password: password,
      deviceId: _deviceId,
      deviceName: deviceName,
      platform: platform,
      totpCode: totpCode,
      recoveryCode: recoveryCode,
    );
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );
    final body = response.data!;

    if (body['mfa_required'] == true) {
      return LoginOutcome.mfaRequired;
    }

    await _tokenStore.save(
      accessToken: body['access_token'] as String,
      refreshToken: body['refresh_token'] as String,
    );
    return LoginOutcome.authenticated;
  }
}
