// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revert_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RevertRequestCWProxy {
  RevertRequest targetServerSeq(int targetServerSeq);

  RevertRequest deviceId(String deviceId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RevertRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RevertRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RevertRequest call({int targetServerSeq, String deviceId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRevertRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRevertRequest.copyWith.fieldName(...)`
class _$RevertRequestCWProxyImpl implements _$RevertRequestCWProxy {
  const _$RevertRequestCWProxyImpl(this._value);

  final RevertRequest _value;

  @override
  RevertRequest targetServerSeq(int targetServerSeq) =>
      this(targetServerSeq: targetServerSeq);

  @override
  RevertRequest deviceId(String deviceId) => this(deviceId: deviceId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RevertRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RevertRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RevertRequest call({
    Object? targetServerSeq = const $CopyWithPlaceholder(),
    Object? deviceId = const $CopyWithPlaceholder(),
  }) {
    return RevertRequest(
      targetServerSeq: targetServerSeq == const $CopyWithPlaceholder()
          ? _value.targetServerSeq
          // ignore: cast_nullable_to_non_nullable
          : targetServerSeq as int,
      deviceId: deviceId == const $CopyWithPlaceholder()
          ? _value.deviceId
          // ignore: cast_nullable_to_non_nullable
          : deviceId as String,
    );
  }
}

extension $RevertRequestCopyWith on RevertRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRevertRequest.copyWith(...)` or like so:`instanceOfRevertRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RevertRequestCWProxy get copyWith => _$RevertRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RevertRequest _$RevertRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'RevertRequest',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['target_server_seq', 'device_id'],
        );
        final val = RevertRequest(
          targetServerSeq: $checkedConvert(
            'target_server_seq',
            (v) => (v as num).toInt(),
          ),
          deviceId: $checkedConvert('device_id', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'targetServerSeq': 'target_server_seq',
        'deviceId': 'device_id',
      },
    );

Map<String, dynamic> _$RevertRequestToJson(RevertRequest instance) =>
    <String, dynamic>{
      'target_server_seq': instance.targetServerSeq,
      'device_id': instance.deviceId,
    };
