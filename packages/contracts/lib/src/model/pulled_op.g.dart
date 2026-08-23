// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pulled_op.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PulledOpCWProxy {
  PulledOp serverSeq(int serverSeq);

  PulledOp clientOpId(String clientOpId);

  PulledOp entityType(String entityType);

  PulledOp entityId(String entityId);

  PulledOp opType(OpType opType);

  PulledOp payload(Map<String, Object> payload);

  PulledOp deviceId(String deviceId);

  PulledOp clientTs(DateTime clientTs);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PulledOp(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PulledOp(...).copyWith(id: 12, name: "My name")
  /// ````
  PulledOp call({
    int serverSeq,
    String clientOpId,
    String entityType,
    String entityId,
    OpType opType,
    Map<String, Object> payload,
    String deviceId,
    DateTime clientTs,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPulledOp.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPulledOp.copyWith.fieldName(...)`
class _$PulledOpCWProxyImpl implements _$PulledOpCWProxy {
  const _$PulledOpCWProxyImpl(this._value);

  final PulledOp _value;

  @override
  PulledOp serverSeq(int serverSeq) => this(serverSeq: serverSeq);

  @override
  PulledOp clientOpId(String clientOpId) => this(clientOpId: clientOpId);

  @override
  PulledOp entityType(String entityType) => this(entityType: entityType);

  @override
  PulledOp entityId(String entityId) => this(entityId: entityId);

  @override
  PulledOp opType(OpType opType) => this(opType: opType);

  @override
  PulledOp payload(Map<String, Object> payload) => this(payload: payload);

  @override
  PulledOp deviceId(String deviceId) => this(deviceId: deviceId);

  @override
  PulledOp clientTs(DateTime clientTs) => this(clientTs: clientTs);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PulledOp(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PulledOp(...).copyWith(id: 12, name: "My name")
  /// ````
  PulledOp call({
    Object? serverSeq = const $CopyWithPlaceholder(),
    Object? clientOpId = const $CopyWithPlaceholder(),
    Object? entityType = const $CopyWithPlaceholder(),
    Object? entityId = const $CopyWithPlaceholder(),
    Object? opType = const $CopyWithPlaceholder(),
    Object? payload = const $CopyWithPlaceholder(),
    Object? deviceId = const $CopyWithPlaceholder(),
    Object? clientTs = const $CopyWithPlaceholder(),
  }) {
    return PulledOp(
      serverSeq: serverSeq == const $CopyWithPlaceholder()
          ? _value.serverSeq
          // ignore: cast_nullable_to_non_nullable
          : serverSeq as int,
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

extension $PulledOpCopyWith on PulledOp {
  /// Returns a callable class that can be used as follows: `instanceOfPulledOp.copyWith(...)` or like so:`instanceOfPulledOp.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PulledOpCWProxy get copyWith => _$PulledOpCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PulledOp _$PulledOpFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PulledOp',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'server_seq',
        'client_op_id',
        'entity_type',
        'entity_id',
        'op_type',
        'payload',
        'device_id',
        'client_ts',
      ],
    );
    final val = PulledOp(
      serverSeq: $checkedConvert('server_seq', (v) => (v as num).toInt()),
      clientOpId: $checkedConvert('client_op_id', (v) => v as String),
      entityType: $checkedConvert('entity_type', (v) => v as String),
      entityId: $checkedConvert('entity_id', (v) => v as String),
      opType: $checkedConvert(
        'op_type',
        (v) => $enumDecode(_$OpTypeEnumMap, v),
      ),
      payload: $checkedConvert(
        'payload',
        (v) =>
            (v as Map<String, dynamic>).map((k, e) => MapEntry(k, e as Object)),
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
    'serverSeq': 'server_seq',
    'clientOpId': 'client_op_id',
    'entityType': 'entity_type',
    'entityId': 'entity_id',
    'opType': 'op_type',
    'deviceId': 'device_id',
    'clientTs': 'client_ts',
  },
);

Map<String, dynamic> _$PulledOpToJson(PulledOp instance) => <String, dynamic>{
  'server_seq': instance.serverSeq,
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
