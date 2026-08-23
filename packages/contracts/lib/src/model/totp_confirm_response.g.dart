// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totp_confirm_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TotpConfirmResponseCWProxy {
  TotpConfirmResponse recoveryCodes(List<String> recoveryCodes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TotpConfirmResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TotpConfirmResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  TotpConfirmResponse call({List<String> recoveryCodes});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTotpConfirmResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTotpConfirmResponse.copyWith.fieldName(...)`
class _$TotpConfirmResponseCWProxyImpl implements _$TotpConfirmResponseCWProxy {
  const _$TotpConfirmResponseCWProxyImpl(this._value);

  final TotpConfirmResponse _value;

  @override
  TotpConfirmResponse recoveryCodes(List<String> recoveryCodes) =>
      this(recoveryCodes: recoveryCodes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TotpConfirmResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TotpConfirmResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  TotpConfirmResponse call({
    Object? recoveryCodes = const $CopyWithPlaceholder(),
  }) {
    return TotpConfirmResponse(
      recoveryCodes: recoveryCodes == const $CopyWithPlaceholder()
          ? _value.recoveryCodes
          // ignore: cast_nullable_to_non_nullable
          : recoveryCodes as List<String>,
    );
  }
}

extension $TotpConfirmResponseCopyWith on TotpConfirmResponse {
  /// Returns a callable class that can be used as follows: `instanceOfTotpConfirmResponse.copyWith(...)` or like so:`instanceOfTotpConfirmResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TotpConfirmResponseCWProxy get copyWith =>
      _$TotpConfirmResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TotpConfirmResponse _$TotpConfirmResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TotpConfirmResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['recovery_codes']);
      final val = TotpConfirmResponse(
        recoveryCodes: $checkedConvert(
          'recovery_codes',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'recoveryCodes': 'recovery_codes'});

Map<String, dynamic> _$TotpConfirmResponseToJson(
  TotpConfirmResponse instance,
) => <String, dynamic>{'recovery_codes': instance.recoveryCodes};
