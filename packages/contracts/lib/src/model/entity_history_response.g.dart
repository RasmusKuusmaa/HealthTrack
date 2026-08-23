// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_history_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntityHistoryResponseCWProxy {
  EntityHistoryResponse history(List<EntityHistoryEntry> history);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntityHistoryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntityHistoryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EntityHistoryResponse call({List<EntityHistoryEntry> history});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntityHistoryResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntityHistoryResponse.copyWith.fieldName(...)`
class _$EntityHistoryResponseCWProxyImpl
    implements _$EntityHistoryResponseCWProxy {
  const _$EntityHistoryResponseCWProxyImpl(this._value);

  final EntityHistoryResponse _value;

  @override
  EntityHistoryResponse history(List<EntityHistoryEntry> history) =>
      this(history: history);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntityHistoryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntityHistoryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EntityHistoryResponse call({Object? history = const $CopyWithPlaceholder()}) {
    return EntityHistoryResponse(
      history: history == const $CopyWithPlaceholder()
          ? _value.history
          // ignore: cast_nullable_to_non_nullable
          : history as List<EntityHistoryEntry>,
    );
  }
}

extension $EntityHistoryResponseCopyWith on EntityHistoryResponse {
  /// Returns a callable class that can be used as follows: `instanceOfEntityHistoryResponse.copyWith(...)` or like so:`instanceOfEntityHistoryResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntityHistoryResponseCWProxy get copyWith =>
      _$EntityHistoryResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityHistoryResponse _$EntityHistoryResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EntityHistoryResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['history']);
  final val = EntityHistoryResponse(
    history: $checkedConvert(
      'history',
      (v) => (v as List<dynamic>)
          .map((e) => EntityHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$EntityHistoryResponseToJson(
  EntityHistoryResponse instance,
) => <String, dynamic>{
  'history': instance.history.map((e) => e.toJson()).toList(),
};
