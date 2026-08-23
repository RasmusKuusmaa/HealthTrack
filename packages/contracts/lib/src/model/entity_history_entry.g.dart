// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_history_entry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntityHistoryEntryCWProxy {
  EntityHistoryEntry serverSeq(int serverSeq);

  EntityHistoryEntry opType(OpType opType);

  EntityHistoryEntry payload(Map<String, Object> payload);

  EntityHistoryEntry deviceId(String deviceId);

  EntityHistoryEntry clientTs(DateTime clientTs);

  EntityHistoryEntry serverTs(DateTime serverTs);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntityHistoryEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntityHistoryEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  EntityHistoryEntry call({
    int serverSeq,
    OpType opType,
    Map<String, Object> payload,
    String deviceId,
    DateTime clientTs,
    DateTime serverTs,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntityHistoryEntry.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntityHistoryEntry.copyWith.fieldName(...)`
class _$EntityHistoryEntryCWProxyImpl implements _$EntityHistoryEntryCWProxy {
  const _$EntityHistoryEntryCWProxyImpl(this._value);

  final EntityHistoryEntry _value;

  @override
  EntityHistoryEntry serverSeq(int serverSeq) => this(serverSeq: serverSeq);

  @override
  EntityHistoryEntry opType(OpType opType) => this(opType: opType);

  @override
  EntityHistoryEntry payload(Map<String, Object> payload) =>
      this(payload: payload);

  @override
  EntityHistoryEntry deviceId(String deviceId) => this(deviceId: deviceId);

  @override
  EntityHistoryEntry clientTs(DateTime clientTs) => this(clientTs: clientTs);

  @override
  EntityHistoryEntry serverTs(DateTime serverTs) => this(serverTs: serverTs);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntityHistoryEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntityHistoryEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  EntityHistoryEntry call({
    Object? serverSeq = const $CopyWithPlaceholder(),
    Object? opType = const $CopyWithPlaceholder(),
    Object? payload = const $CopyWithPlaceholder(),
    Object? deviceId = const $CopyWithPlaceholder(),
    Object? clientTs = const $CopyWithPlaceholder(),
    Object? serverTs = const $CopyWithPlaceholder(),
  }) {
    return EntityHistoryEntry(
      serverSeq: serverSeq == const $CopyWithPlaceholder()
          ? _value.serverSeq
          // ignore: cast_nullable_to_non_nullable
          : serverSeq as int,
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
      serverTs: serverTs == const $CopyWithPlaceholder()
          ? _value.serverTs
          // ignore: cast_nullable_to_non_nullable
          : serverTs as DateTime,
    );
  }
}

extension $EntityHistoryEntryCopyWith on EntityHistoryEntry {
  /// Returns a callable class that can be used as follows: `instanceOfEntityHistoryEntry.copyWith(...)` or like so:`instanceOfEntityHistoryEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntityHistoryEntryCWProxy get copyWith =>
      _$EntityHistoryEntryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityHistoryEntry _$EntityHistoryEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'EntityHistoryEntry',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'server_seq',
            'op_type',
            'payload',
            'device_id',
            'client_ts',
            'server_ts',
          ],
        );
        final val = EntityHistoryEntry(
          serverSeq: $checkedConvert('server_seq', (v) => (v as num).toInt()),
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
          serverTs: $checkedConvert(
            'server_ts',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'serverSeq': 'server_seq',
        'opType': 'op_type',
        'deviceId': 'device_id',
        'clientTs': 'client_ts',
        'serverTs': 'server_ts',
      },
    );

Map<String, dynamic> _$EntityHistoryEntryToJson(EntityHistoryEntry instance) =>
    <String, dynamic>{
      'server_seq': instance.serverSeq,
      'op_type': _$OpTypeEnumMap[instance.opType]!,
      'payload': instance.payload,
      'device_id': instance.deviceId,
      'client_ts': instance.clientTs.toIso8601String(),
      'server_ts': instance.serverTs.toIso8601String(),
    };

const _$OpTypeEnumMap = {
  OpType.create: 'create',
  OpType.update: 'update',
  OpType.delete: 'delete',
};
