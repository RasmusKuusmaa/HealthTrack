// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_op_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PushOpRequestCWProxy {
  PushOpRequest clientOpId(String clientOpId);

  PushOpRequest entityType(String entityType);

  PushOpRequest entityId(String entityId);

  PushOpRequest opType(OpType opType);

  PushOpRequest payload(Map<String, Object> payload);

  PushOpRequest deviceId(String deviceId);

  PushOpRequest clientTs(DateTime clientTs);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushOpRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushOpRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PushOpRequest call({
    String clientOpId,
    String entityType,
    String entityId,
    OpType opType,
    Map<String, Object> payload,
    String deviceId,
    DateTime clientTs,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPushOpRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPushOpRequest.copyWith.fieldName(...)`
class _$PushOpRequestCWProxyImpl implements _$PushOpRequestCWProxy {
  const _$PushOpRequestCWProxyImpl(this._value);

  final PushOpRequest _value;

  @override
  PushOpRequest clientOpId(String clientOpId) => this(clientOpId: clientOpId);

  @override
  PushOpRequest entityType(String entityType) => this(entityType: entityType);

  @override
  PushOpRequest entityId(String entityId) => this(entityId: entityId);

  @override
  PushOpRequest opType(OpType opType) => this(opType: opType);

  @override
  PushOpRequest payload(Map<String, Object> payload) => this(payload: payload);

  @override
  PushOpRequest deviceId(String deviceId) => this(deviceId: deviceId);

  @override
  PushOpRequest clientTs(DateTime clientTs) => this(clientTs: clientTs);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushOpRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushOpRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PushOpRequest call({
    Object? clientOpId = const $CopyWithPlaceholder(),
    Object? entityType = const $CopyWithPlaceholder(),
    Object? entityId = const $CopyWithPlaceholder(),
    Object? opType = const $CopyWithPlaceholder(),
    Object? payload = const $CopyWithPlaceholder(),
    Object? deviceId = const $CopyWithPlaceholder(),
    Object? clientTs = const $CopyWithPlaceholder(),
  }) {
    return PushOpRequest(
      clientOpId: clientOpId == const $CopyWithPlaceholder()
          ? _value.clientOpId
          // ignore: cast_nullable_to_non_nullable
          : clientOpId as String,
      entityType: entityType == const $CopyWithPlaceholder()
          ? _value.entityType
          // ignore: cast_nullable_to_non_nullable
          : entityType as String,
      entityId: entityId == const $CopyWithPlaceholder()
          ? _value.entityId
          // ignore: cast_nullable_to_non_nullable
          : entityId as String,
      opType: opType == const $CopyWithPlaceholder()
          ? _value.opType
          // ignore: cast_nullable_to_non_nullable
          : opType as OpType,
      payload: payload == const $CopyWithPlaceholder()
          ? _value.payload
          // ignore: cast_nullable_to_non_nullable
          : payload as Map<String, Object>,
      deviceId: deviceId == const $CopyWithPlaceholder()
          ? _value.deviceId
          // ignore: cast_nullable_to_non_nullable
          : deviceId as String,
      clientTs: clientTs == const $CopyWithPlaceholder()
          ? _value.clientTs
          // ignore: cast_nullable_to_non_nullable
          : clientTs as DateTime,
    );
  }
}

extension $PushOpRequestCopyWith on PushOpRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPushOpRequest.copyWith(...)` or like so:`instanceOfPushOpRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PushOpRequestCWProxy get copyWith => _$PushOpRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushOpRequest _$PushOpRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PushOpRequest',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'client_op_id',
            'entity_type',
            'entity_id',
            'op_type',
            'payload',
            'device_id',
            'client_ts',
          ],
        );
        final val = PushOpRequest(
          clientOpId: $checkedConvert('client_op_id', (v) => v as String),
          entityType: $checkedConvert('entity_type', (v) => v as String),
          entityId: $checkedConvert('entity_id', (v) => v as String),
          opType: $checkedConvert(
            'op_type',
            (v) => $enumDecode(_$OpTypeEnumMap, v),
          ),
          payload: $checkedConvert(
            'payload',
            (v) => (v as Map<String, dynamic>).map(
              (k, e) => MapEntry(k, e as Object),
            ),
          ),
          deviceId: $checkedConvert('device_id', (v) => v as String),
          clientTs: $checkedConvert(
            'client_ts',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'clientOpId': 'client_op_id',
        'entityType': 'entity_type',
        'entityId': 'entity_id',
        'opType': 'op_type',
        'deviceId': 'device_id',
        'clientTs': 'client_ts',
      },
    );

Map<String, dynamic> _$PushOpRequestToJson(PushOpRequest instance) =>
    <String, dynamic>{
      'client_op_id': instance.clientOpId,
      'entity_type': instance.entityType,
      'entity_id': instance.entityId,
      'op_type': _$OpTypeEnumMap[instance.opType]!,
      'payload': instance.payload,
      'device_id': instance.deviceId,
      'client_ts': instance.clientTs.toIso8601String(),
    };

const _$OpTypeEnumMap = {
  OpType.create: 'create',
  OpType.update: 'update',
  OpType.delete: 'delete',
};
