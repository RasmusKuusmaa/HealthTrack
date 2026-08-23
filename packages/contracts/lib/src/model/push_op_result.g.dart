// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_op_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PushOpResultCWProxy {
  PushOpResult clientOpId(String clientOpId);

  PushOpResult serverSeq(int serverSeq);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushOpResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushOpResult(...).copyWith(id: 12, name: "My name")
  /// ````
  PushOpResult call({String clientOpId, int serverSeq});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPushOpResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPushOpResult.copyWith.fieldName(...)`
class _$PushOpResultCWProxyImpl implements _$PushOpResultCWProxy {
  const _$PushOpResultCWProxyImpl(this._value);

  final PushOpResult _value;

  @override
  PushOpResult clientOpId(String clientOpId) => this(clientOpId: clientOpId);

  @override
  PushOpResult serverSeq(int serverSeq) => this(serverSeq: serverSeq);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushOpResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushOpResult(...).copyWith(id: 12, name: "My name")
  /// ````
  PushOpResult call({
    Object? clientOpId = const $CopyWithPlaceholder(),
    Object? serverSeq = const $CopyWithPlaceholder(),
  }) {
    return PushOpResult(
      clientOpId: clientOpId == const $CopyWithPlaceholder()
          ? _value.clientOpId
          // ignore: cast_nullable_to_non_nullable
          : clientOpId as String,
      serverSeq: serverSeq == const $CopyWithPlaceholder()
          ? _value.serverSeq
          // ignore: cast_nullable_to_non_nullable
          : serverSeq as int,
    );
  }
}

extension $PushOpResultCopyWith on PushOpResult {
  /// Returns a callable class that can be used as follows: `instanceOfPushOpResult.copyWith(...)` or like so:`instanceOfPushOpResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PushOpResultCWProxy get copyWith => _$PushOpResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushOpResult _$PushOpResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PushOpResult',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['client_op_id', 'server_seq']);
        final val = PushOpResult(
          clientOpId: $checkedConvert('client_op_id', (v) => v as String),
          serverSeq: $checkedConvert('server_seq', (v) => (v as num).toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'clientOpId': 'client_op_id',
        'serverSeq': 'server_seq',
      },
    );

Map<String, dynamic> _$PushOpResultToJson(PushOpResult instance) =>
    <String, dynamic>{
      'client_op_id': instance.clientOpId,
      'server_seq': instance.serverSeq,
    };
