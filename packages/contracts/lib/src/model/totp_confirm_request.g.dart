// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totp_confirm_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TotpConfirmRequestCWProxy {
  TotpConfirmRequest code(String code);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TotpConfirmRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TotpConfirmRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  TotpConfirmRequest call({String code});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTotpConfirmRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTotpConfirmRequest.copyWith.fieldName(...)`
class _$TotpConfirmRequestCWProxyImpl implements _$TotpConfirmRequestCWProxy {
  const _$TotpConfirmRequestCWProxyImpl(this._value);

  final TotpConfirmRequest _value;

  @override
  TotpConfirmRequest code(String code) => this(code: code);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TotpConfirmRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TotpConfirmRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  TotpConfirmRequest call({Object? code = const $CopyWithPlaceholder()}) {
    return TotpConfirmRequest(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
    );
  }
}

extension $TotpConfirmRequestCopyWith on TotpConfirmRequest {
  /// Returns a callable class that can be used as follows: `instanceOfTotpConfirmRequest.copyWith(...)` or like so:`instanceOfTotpConfirmRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TotpConfirmRequestCWProxy get copyWith =>
      _$TotpConfirmRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TotpConfirmRequest _$TotpConfirmRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TotpConfirmRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code']);
      final val = TotpConfirmRequest(
        code: $checkedConvert('code', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$TotpConfirmRequestToJson(TotpConfirmRequest instance) =>
    <String, dynamic>{'code': instance.code};
