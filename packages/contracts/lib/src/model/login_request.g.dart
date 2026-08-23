// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LoginRequestCWProxy {
  LoginRequest email(String email);

  LoginRequest password(String password);

  LoginRequest deviceId(String deviceId);

  LoginRequest deviceName(String? deviceName);

  LoginRequest platform(DevicePlatform? platform);

  LoginRequest totpCode(String? totpCode);

  LoginRequest recoveryCode(String? recoveryCode);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LoginRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LoginRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  LoginRequest call({
    String email,
    String password,
    String deviceId,
    String? deviceName,
    DevicePlatform? platform,
    String? totpCode,
    String? recoveryCode,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLoginRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLoginRequest.copyWith.fieldName(...)`
class _$LoginRequestCWProxyImpl implements _$LoginRequestCWProxy {
  const _$LoginRequestCWProxyImpl(this._value);

  final LoginRequest _value;

  @override
  LoginRequest email(String email) => this(email: email);

  @override
  LoginRequest password(String password) => this(password: password);

  @override
  LoginRequest deviceId(String deviceId) => this(deviceId: deviceId);

  @override
  LoginRequest deviceName(String? deviceName) => this(deviceName: deviceName);

  @override
  LoginRequest platform(DevicePlatform? platform) => this(platform: platform);

  @override
  LoginRequest totpCode(String? totpCode) => this(totpCode: totpCode);

  @override
  LoginRequest recoveryCode(String? recoveryCode) =>
      this(recoveryCode: recoveryCode);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LoginRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LoginRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  LoginRequest call({
    Object? email = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
    Object? deviceId = const $CopyWithPlaceholder(),
    Object? deviceName = const $CopyWithPlaceholder(),
    Object? platform = const $CopyWithPlaceholder(),
    Object? totpCode = const $CopyWithPlaceholder(),
    Object? recoveryCode = const $CopyWithPlaceholder(),
  }) {
    return LoginRequest(
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String,
      deviceId: deviceId == const $CopyWithPlaceholder()
          ? _value.deviceId
          // ignore: cast_nullable_to_non_nullable
          : deviceId as String,
      deviceName: deviceName == const $CopyWithPlaceholder()
          ? _value.deviceName
          // ignore: cast_nullable_to_non_nullable
          : deviceName as String?,
      platform: platform == const $CopyWithPlaceholder()
          ? _value.platform
          // ignore: cast_nullable_to_non_nullable
          : platform as DevicePlatform?,
      totpCode: totpCode == const $CopyWithPlaceholder()
          ? _value.totpCode
          // ignore: cast_nullable_to_non_nullable
          : totpCode as String?,
      recoveryCode: recoveryCode == const $CopyWithPlaceholder()
          ? _value.recoveryCode
          // ignore: cast_nullable_to_non_nullable
          : recoveryCode as String?,
    );
  }
}

extension $LoginRequestCopyWith on LoginRequest {
  /// Returns a callable class that can be used as follows: `instanceOfLoginRequest.copyWith(...)` or like so:`instanceOfLoginRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LoginRequestCWProxy get copyWith => _$LoginRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LoginRequest',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['email', 'password', 'device_id'],
        );
        final val = LoginRequest(
          email: $checkedConvert('email', (v) => v as String),
          password: $checkedConvert('password', (v) => v as String),
          deviceId: $checkedConvert('device_id', (v) => v as String),
          deviceName: $checkedConvert(
            'device_name',
            (v) => v as String? ?? 'Unknown device',
          ),
          platform: $checkedConvert(
            'platform',
            (v) =>
                $enumDecodeNullable(_$DevicePlatformEnumMap, v) ??
                DevicePlatform.web,
          ),
          totpCode: $checkedConvert('totp_code', (v) => v as String?),
          recoveryCode: $checkedConvert('recovery_code', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'deviceId': 'device_id',
        'deviceName': 'device_name',
        'totpCode': 'totp_code',
        'recoveryCode': 'recovery_code',
      },
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'device_id': instance.deviceId,
      'device_name': ?instance.deviceName,
      'platform': ?_$DevicePlatformEnumMap[instance.platform],
      'totp_code': ?instance.totpCode,
      'recovery_code': ?instance.recoveryCode,
    };

const _$DevicePlatformEnumMap = {
  DevicePlatform.ios: 'ios',
  DevicePlatform.android: 'android',
  DevicePlatform.web: 'web',
};
