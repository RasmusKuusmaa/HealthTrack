// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totp_enroll_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TotpEnrollResponseCWProxy {
  TotpEnrollResponse provisioningUri(String provisioningUri);

  TotpEnrollResponse qrCodePngBase64(String qrCodePngBase64);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TotpEnrollResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TotpEnrollResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  TotpEnrollResponse call({String provisioningUri, String qrCodePngBase64});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTotpEnrollResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTotpEnrollResponse.copyWith.fieldName(...)`
class _$TotpEnrollResponseCWProxyImpl implements _$TotpEnrollResponseCWProxy {
  const _$TotpEnrollResponseCWProxyImpl(this._value);

  final TotpEnrollResponse _value;

  @override
  TotpEnrollResponse provisioningUri(String provisioningUri) =>
      this(provisioningUri: provisioningUri);

  @override
  TotpEnrollResponse qrCodePngBase64(String qrCodePngBase64) =>
      this(qrCodePngBase64: qrCodePngBase64);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TotpEnrollResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TotpEnrollResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  TotpEnrollResponse call({
    Object? provisioningUri = const $CopyWithPlaceholder(),
    Object? qrCodePngBase64 = const $CopyWithPlaceholder(),
  }) {
    return TotpEnrollResponse(
      provisioningUri: provisioningUri == const $CopyWithPlaceholder()
          ? _value.provisioningUri
          // ignore: cast_nullable_to_non_nullable
          : provisioningUri as String,
      qrCodePngBase64: qrCodePngBase64 == const $CopyWithPlaceholder()
          ? _value.qrCodePngBase64
          // ignore: cast_nullable_to_non_nullable
          : qrCodePngBase64 as String,
    );
  }
}

extension $TotpEnrollResponseCopyWith on TotpEnrollResponse {
  /// Returns a callable class that can be used as follows: `instanceOfTotpEnrollResponse.copyWith(...)` or like so:`instanceOfTotpEnrollResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TotpEnrollResponseCWProxy get copyWith =>
      _$TotpEnrollResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TotpEnrollResponse _$TotpEnrollResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'TotpEnrollResponse',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['provisioning_uri', 'qr_code_png_base64'],
        );
        final val = TotpEnrollResponse(
          provisioningUri: $checkedConvert(
            'provisioning_uri',
            (v) => v as String,
          ),
          qrCodePngBase64: $checkedConvert(
            'qr_code_png_base64',
            (v) => v as String,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'provisioningUri': 'provisioning_uri',
        'qrCodePngBase64': 'qr_code_png_base64',
      },
    );

Map<String, dynamic> _$TotpEnrollResponseToJson(TotpEnrollResponse instance) =>
    <String, dynamic>{
      'provisioning_uri': instance.provisioningUri,
      'qr_code_png_base64': instance.qrCodePngBase64,
    };
