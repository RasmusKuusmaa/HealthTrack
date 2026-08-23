// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PullResponseCWProxy {
  PullResponse ops(List<PulledOp> ops);

  PullResponse nextCursor(int nextCursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PullResponse call({List<PulledOp> ops, int nextCursor});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPullResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPullResponse.copyWith.fieldName(...)`
class _$PullResponseCWProxyImpl implements _$PullResponseCWProxy {
  const _$PullResponseCWProxyImpl(this._value);

  final PullResponse _value;

  @override
  PullResponse ops(List<PulledOp> ops) => this(ops: ops);

  @override
  PullResponse nextCursor(int nextCursor) => this(nextCursor: nextCursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PullResponse call({
    Object? ops = const $CopyWithPlaceholder(),
    Object? nextCursor = const $CopyWithPlaceholder(),
  }) {
    return PullResponse(
      ops: ops == const $CopyWithPlaceholder()
          ? _value.ops
          // ignore: cast_nullable_to_non_nullable
          : ops as List<PulledOp>,
      nextCursor: nextCursor == const $CopyWithPlaceholder()
          ? _value.nextCursor
          // ignore: cast_nullable_to_non_nullable
          : nextCursor as int,
    );
  }
}

extension $PullResponseCopyWith on PullResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPullResponse.copyWith(...)` or like so:`instanceOfPullResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PullResponseCWProxy get copyWith => _$PullResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullResponse _$PullResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PullResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['ops', 'next_cursor']);
      final val = PullResponse(
        ops: $checkedConvert(
          'ops',
          (v) => (v as List<dynamic>)
              .map((e) => PulledOp.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        nextCursor: $checkedConvert('next_cursor', (v) => (v as num).toInt()),
      );
      return val;
    }, fieldKeyMap: const {'nextCursor': 'next_cursor'});

Map<String, dynamic> _$PullResponseToJson(PullResponse instance) =>
    <String, dynamic>{
      'ops': instance.ops.map((e) => e.toJson()).toList(),
      'next_cursor': instance.nextCursor,
    };
