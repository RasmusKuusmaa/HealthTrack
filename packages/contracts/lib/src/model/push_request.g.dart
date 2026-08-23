// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PushRequestCWProxy {
  PushRequest ops(List<PushOpRequest> ops);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PushRequest call({List<PushOpRequest> ops});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPushRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPushRequest.copyWith.fieldName(...)`
class _$PushRequestCWProxyImpl implements _$PushRequestCWProxy {
  const _$PushRequestCWProxyImpl(this._value);

  final PushRequest _value;

  @override
  PushRequest ops(List<PushOpRequest> ops) => this(ops: ops);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PushRequest call({Object? ops = const $CopyWithPlaceholder()}) {
    return PushRequest(
      ops: ops == const $CopyWithPlaceholder()
          ? _value.ops
          // ignore: cast_nullable_to_non_nullable
          : ops as List<PushOpRequest>,
    );
  }
}

extension $PushRequestCopyWith on PushRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPushRequest.copyWith(...)` or like so:`instanceOfPushRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PushRequestCWProxy get copyWith => _$PushRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushRequest _$PushRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PushRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['ops']);
      final val = PushRequest(
        ops: $checkedConvert(
          'ops',
          (v) => (v as List<dynamic>)
              .map((e) => PushOpRequest.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PushRequestToJson(PushRequest instance) =>
    <String, dynamic>{'ops': instance.ops.map((e) => e.toJson()).toList()};
