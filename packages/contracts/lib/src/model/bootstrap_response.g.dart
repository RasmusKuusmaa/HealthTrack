// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BootstrapResponseCWProxy {
  BootstrapResponse entities(Map<String, List<Map<String, Object>>> entities);

  BootstrapResponse cursor(int cursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BootstrapResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BootstrapResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BootstrapResponse call({
    Map<String, List<Map<String, Object>>> entities,
    int cursor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBootstrapResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBootstrapResponse.copyWith.fieldName(...)`
class _$BootstrapResponseCWProxyImpl implements _$BootstrapResponseCWProxy {
  const _$BootstrapResponseCWProxyImpl(this._value);

  final BootstrapResponse _value;

  @override
  BootstrapResponse entities(Map<String, List<Map<String, Object>>> entities) =>
      this(entities: entities);

  @override
  BootstrapResponse cursor(int cursor) => this(cursor: cursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BootstrapResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BootstrapResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BootstrapResponse call({
    Object? entities = const $CopyWithPlaceholder(),
    Object? cursor = const $CopyWithPlaceholder(),
  }) {
    return BootstrapResponse(
      entities: entities == const $CopyWithPlaceholder()
          ? _value.entities
          // ignore: cast_nullable_to_non_nullable
          : entities as Map<String, List<Map<String, Object>>>,
      cursor: cursor == const $CopyWithPlaceholder()
          ? _value.cursor
          // ignore: cast_nullable_to_non_nullable
          : cursor as int,
    );
  }
}

extension $BootstrapResponseCopyWith on BootstrapResponse {
  /// Returns a callable class that can be used as follows: `instanceOfBootstrapResponse.copyWith(...)` or like so:`instanceOfBootstrapResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BootstrapResponseCWProxy get copyWith =>
      _$BootstrapResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BootstrapResponse _$BootstrapResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BootstrapResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['entities', 'cursor']);
      final val = BootstrapResponse(
        entities: $checkedConvert(
          'entities',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>)
                  .map(
                    (e) => (e as Map<String, dynamic>).map(
                      (k, e) => MapEntry(k, e as Object),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        cursor: $checkedConvert('cursor', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$BootstrapResponseToJson(BootstrapResponse instance) =>
    <String, dynamic>{'entities': instance.entities, 'cursor': instance.cursor};
