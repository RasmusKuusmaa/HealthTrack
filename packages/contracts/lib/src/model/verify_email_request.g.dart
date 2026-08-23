// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VerifyEmailRequestCWProxy {
  VerifyEmailRequest token(String token);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VerifyEmailRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VerifyEmailRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  VerifyEmailRequest call({String token});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVerifyEmailRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVerifyEmailRequest.copyWith.fieldName(...)`
class _$VerifyEmailRequestCWProxyImpl implements _$VerifyEmailRequestCWProxy {
  const _$VerifyEmailRequestCWProxyImpl(this._value);

  final VerifyEmailRequest _value;

  @override
  VerifyEmailRequest token(String token) => this(token: token);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VerifyEmailRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VerifyEmailRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  VerifyEmailRequest call({Object? token = const $CopyWithPlaceholder()}) {
    return VerifyEmailRequest(
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
    );
  }
}

extension $VerifyEmailRequestCopyWith on VerifyEmailRequest {
  /// Returns a callable class that can be used as follows: `instanceOfVerifyEmailRequest.copyWith(...)` or like so:`instanceOfVerifyEmailRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VerifyEmailRequestCWProxy get copyWith =>
      _$VerifyEmailRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyEmailRequest _$VerifyEmailRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('VerifyEmailRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['token']);
      final val = VerifyEmailRequest(
        token: $checkedConvert('token', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$VerifyEmailRequestToJson(VerifyEmailRequest instance) =>
    <String, dynamic>{'token': instance.token};
