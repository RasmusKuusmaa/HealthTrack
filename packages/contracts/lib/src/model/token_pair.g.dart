// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_pair.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TokenPairCWProxy {
  TokenPair accessToken(String accessToken);

  TokenPair refreshToken(String refreshToken);

  TokenPair tokenType(String? tokenType);

  TokenPair expiresIn(int expiresIn);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TokenPair(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TokenPair(...).copyWith(id: 12, name: "My name")
  /// ````
  TokenPair call({
    String accessToken,
    String refreshToken,
    String? tokenType,
    int expiresIn,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTokenPair.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTokenPair.copyWith.fieldName(...)`
class _$TokenPairCWProxyImpl implements _$TokenPairCWProxy {
  const _$TokenPairCWProxyImpl(this._value);

  final TokenPair _value;

  @override
  TokenPair accessToken(String accessToken) => this(accessToken: accessToken);

  @override
  TokenPair refreshToken(String refreshToken) =>
      this(refreshToken: refreshToken);

  @override
  TokenPair tokenType(String? tokenType) => this(tokenType: tokenType);

  @override
  TokenPair expiresIn(int expiresIn) => this(expiresIn: expiresIn);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TokenPair(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TokenPair(...).copyWith(id: 12, name: "My name")
  /// ````
  TokenPair call({
    Object? accessToken = const $CopyWithPlaceholder(),
    Object? refreshToken = const $CopyWithPlaceholder(),
    Object? tokenType = const $CopyWithPlaceholder(),
    Object? expiresIn = const $CopyWithPlaceholder(),
  }) {
    return TokenPair(
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
    );
  }
}

extension $TokenPairCopyWith on TokenPair {
  /// Returns a callable class that can be used as follows: `instanceOfTokenPair.copyWith(...)` or like so:`instanceOfTokenPair.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TokenPairCWProxy get copyWith => _$TokenPairCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenPair _$TokenPairFromJson(Map<String, dynamic> json) => $checkedCreate(
  'TokenPair',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['access_token', 'refresh_token', 'expires_in'],
    );
    final val = TokenPair(
      accessToken: $checkedConvert('access_token', (v) => v as String),
      refreshToken: $checkedConvert('refresh_token', (v) => v as String),
      tokenType: $checkedConvert('token_type', (v) => v as String? ?? 'bearer'),
      expiresIn: $checkedConvert('expires_in', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'accessToken': 'access_token',
    'refreshToken': 'refresh_token',
    'tokenType': 'token_type',
    'expiresIn': 'expires_in',
  },
);

Map<String, dynamic> _$TokenPairToJson(TokenPair instance) => <String, dynamic>{
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'token_type': ?instance.tokenType,
  'expires_in': instance.expiresIn,
};
