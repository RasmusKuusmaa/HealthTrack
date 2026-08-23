// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_login_auth_login_post.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ResponseLoginAuthLoginPostCWProxy {
  ResponseLoginAuthLoginPost accessToken(String accessToken);

  ResponseLoginAuthLoginPost refreshToken(String refreshToken);

  ResponseLoginAuthLoginPost tokenType(String? tokenType);

  ResponseLoginAuthLoginPost expiresIn(int expiresIn);

  ResponseLoginAuthLoginPost mfaRequired(bool? mfaRequired);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ResponseLoginAuthLoginPost(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ResponseLoginAuthLoginPost(...).copyWith(id: 12, name: "My name")
  /// ````
  ResponseLoginAuthLoginPost call({
    String accessToken,
    String refreshToken,
    String? tokenType,
    int expiresIn,
    bool? mfaRequired,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfResponseLoginAuthLoginPost.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfResponseLoginAuthLoginPost.copyWith.fieldName(...)`
class _$ResponseLoginAuthLoginPostCWProxyImpl
    implements _$ResponseLoginAuthLoginPostCWProxy {
  const _$ResponseLoginAuthLoginPostCWProxyImpl(this._value);

  final ResponseLoginAuthLoginPost _value;

  @override
  ResponseLoginAuthLoginPost accessToken(String accessToken) =>
      this(accessToken: accessToken);

  @override
  ResponseLoginAuthLoginPost refreshToken(String refreshToken) =>
      this(refreshToken: refreshToken);

  @override
  ResponseLoginAuthLoginPost tokenType(String? tokenType) =>
      this(tokenType: tokenType);

  @override
  ResponseLoginAuthLoginPost expiresIn(int expiresIn) =>
      this(expiresIn: expiresIn);

  @override
  ResponseLoginAuthLoginPost mfaRequired(bool? mfaRequired) =>
      this(mfaRequired: mfaRequired);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ResponseLoginAuthLoginPost(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ResponseLoginAuthLoginPost(...).copyWith(id: 12, name: "My name")
  /// ````
  ResponseLoginAuthLoginPost call({
    Object? accessToken = const $CopyWithPlaceholder(),
    Object? refreshToken = const $CopyWithPlaceholder(),
    Object? tokenType = const $CopyWithPlaceholder(),
    Object? expiresIn = const $CopyWithPlaceholder(),
    Object? mfaRequired = const $CopyWithPlaceholder(),
  }) {
    return ResponseLoginAuthLoginPost(
      accessToken: accessToken == const $CopyWithPlaceholder()
          ? _value.accessToken
          // ignore: cast_nullable_to_non_nullable
          : accessToken as String,
      refreshToken: refreshToken == const $CopyWithPlaceholder()
          ? _value.refreshToken
          // ignore: cast_nullable_to_non_nullable
          : refreshToken as String,
      tokenType: tokenType == const $CopyWithPlaceholder()
          ? _value.tokenType
          // ignore: cast_nullable_to_non_nullable
          : tokenType as String?,
      expiresIn: expiresIn == const $CopyWithPlaceholder()
          ? _value.expiresIn
          // ignore: cast_nullable_to_non_nullable
          : expiresIn as int,
      mfaRequired: mfaRequired == const $CopyWithPlaceholder()
          ? _value.mfaRequired
          // ignore: cast_nullable_to_non_nullable
          : mfaRequired as bool?,
    );
  }
}

extension $ResponseLoginAuthLoginPostCopyWith on ResponseLoginAuthLoginPost {
  /// Returns a callable class that can be used as follows: `instanceOfResponseLoginAuthLoginPost.copyWith(...)` or like so:`instanceOfResponseLoginAuthLoginPost.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ResponseLoginAuthLoginPostCWProxy get copyWith =>
      _$ResponseLoginAuthLoginPostCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseLoginAuthLoginPost _$ResponseLoginAuthLoginPostFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ResponseLoginAuthLoginPost',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['access_token', 'refresh_token', 'expires_in'],
    );
    final val = ResponseLoginAuthLoginPost(
      accessToken: $checkedConvert('access_token', (v) => v as String),
      refreshToken: $checkedConvert('refresh_token', (v) => v as String),
      tokenType: $checkedConvert('token_type', (v) => v as String? ?? 'bearer'),
      expiresIn: $checkedConvert('expires_in', (v) => (v as num).toInt()),
      mfaRequired: $checkedConvert('mfa_required', (v) => v as bool? ?? true),
    );
    return val;
  },
  fieldKeyMap: const {
    'accessToken': 'access_token',
    'refreshToken': 'refresh_token',
    'tokenType': 'token_type',
    'expiresIn': 'expires_in',
    'mfaRequired': 'mfa_required',
  },
);

Map<String, dynamic> _$ResponseLoginAuthLoginPostToJson(
  ResponseLoginAuthLoginPost instance,
) => <String, dynamic>{
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'token_type': ?instance.tokenType,
  'expires_in': instance.expiresIn,
  'mfa_required': ?instance.mfaRequired,
};
