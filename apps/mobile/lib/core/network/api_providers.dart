import 'package:dio/dio.dart';
import 'package:healthtrack_api_client/healthtrack_api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/secure/device_id_store.dart';
import '../../data/secure/secure_key_value_store.dart';
import '../../data/secure/token_store.dart';
import '../../features/auth/auth_repository.dart';
import '../flavor.dart';
import 'auth_interceptor.dart';

part 'api_providers.g.dart';

@riverpod
SecureKeyValueStore secureKeyValueStore(Ref ref) =>
    const FlutterSecureKeyValueStore();

@riverpod
TokenStore tokenStore(Ref ref) =>
    TokenStore(ref.watch(secureKeyValueStoreProvider));

@riverpod
Future<String> deviceId(Ref ref) {
  return DeviceIdStore(ref.watch(secureKeyValueStoreProvider)).read();
}

/// The shared `Dio` used for every authenticated API call, with
/// [AuthInterceptor] attached. Refreshing uses a separate, interceptor-free
/// `Dio` so a refresh call can never itself recurse through 401 handling.
@riverpod
Future<Dio> apiDio(Ref ref) async {
  final resolvedDeviceId = await ref.watch(deviceIdProvider.future);
  final tokenStore = ref.watch(tokenStoreProvider);

  final refreshDio = Dio(BaseOptions(baseUrl: AppConfig.instance.apiBaseUrl));
  final dio = Dio(BaseOptions(baseUrl: AppConfig.instance.apiBaseUrl));
  dio.interceptors.add(
    AuthInterceptor(
      dio: refreshDio,
      tokenStore: tokenStore,
      deviceId: resolvedDeviceId,
      refreshTokens: DioTokenRefresher(refreshDio).call,
    ),
  );
  return dio;
}

@riverpod
Future<AuthRepository> authRepository(Ref ref) async {
  final dio = await ref.watch(apiDioProvider.future);
  final resolvedDeviceId = await ref.watch(deviceIdProvider.future);
  return AuthRepository(
    dio: dio,
    authApi: AuthApi(dio),
    tokenStore: ref.watch(tokenStoreProvider),
    deviceId: resolvedDeviceId,
  );
}
