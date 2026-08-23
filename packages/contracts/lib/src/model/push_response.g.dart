// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PushResponseCWProxy {
  PushResponse results(List<PushOpResult> results);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PushResponse call({List<PushOpResult> results});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPushResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPushResponse.copyWith.fieldName(...)`
class _$PushResponseCWProxyImpl implements _$PushResponseCWProxy {
  const _$PushResponseCWProxyImpl(this._value);

  final PushResponse _value;

  @override
  PushResponse results(List<PushOpResult> results) => this(results: results);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PushResponse call({Object? results = const $CopyWithPlaceholder()}) {
    return PushResponse(
      results: results == const $CopyWithPlaceholder()
          ? _value.results
          // ignore: cast_nullable_to_non_nullable
          : results as List<PushOpResult>,
    );
  }
}

extension $PushResponseCopyWith on PushResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPushResponse.copyWith(...)` or like so:`instanceOfPushResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PushResponseCWProxy get copyWith => _$PushResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushResponse _$PushResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PushResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['results']);
      final val = PushResponse(
        results: $checkedConvert(
          'results',
          (v) => (v as List<dynamic>)
              .map((e) => PushOpResult.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PushResponseToJson(PushResponse instance) =>
    <String, dynamic>{
      'results': instance.results.map((e) => e.toJson()).toList(),
    };
