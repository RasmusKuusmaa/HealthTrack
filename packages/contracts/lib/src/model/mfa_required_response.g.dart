// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_required_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MfaRequiredResponseCWProxy {
  MfaRequiredResponse mfaRequired(bool? mfaRequired);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MfaRequiredResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MfaRequiredResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MfaRequiredResponse call({bool? mfaRequired});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMfaRequiredResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMfaRequiredResponse.copyWith.fieldName(...)`
class _$MfaRequiredResponseCWProxyImpl implements _$MfaRequiredResponseCWProxy {
  const _$MfaRequiredResponseCWProxyImpl(this._value);

  final MfaRequiredResponse _value;

  @override
  MfaRequiredResponse mfaRequired(bool? mfaRequired) =>
      this(mfaRequired: mfaRequired);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MfaRequiredResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MfaRequiredResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MfaRequiredResponse call({
    Object? mfaRequired = const $CopyWithPlaceholder(),
  }) {
    return MfaRequiredResponse(
      mfaRequired: mfaRequired == const $CopyWithPlaceholder()
          ? _value.mfaRequired
          // ignore: cast_nullable_to_non_nullable
          : mfaRequired as bool?,
    );
  }
}

extension $MfaRequiredResponseCopyWith on MfaRequiredResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMfaRequiredResponse.copyWith(...)` or like so:`instanceOfMfaRequiredResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MfaRequiredResponseCWProxy get copyWith =>
      _$MfaRequiredResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MfaRequiredResponse _$MfaRequiredResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MfaRequiredResponse', json, ($checkedConvert) {
      final val = MfaRequiredResponse(
        mfaRequired: $checkedConvert('mfa_required', (v) => v as bool? ?? true),
      );
      return val;
    }, fieldKeyMap: const {'mfaRequired': 'mfa_required'});

Map<String, dynamic> _$MfaRequiredResponseToJson(
  MfaRequiredResponse instance,
) => <String, dynamic>{'mfa_required': ?instance.mfaRequired};
