// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_out.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeviceOutCWProxy {
  DeviceOut id(String id);

  DeviceOut name(String name);

  DeviceOut platform(DevicePlatform platform);

  DeviceOut lastSeenAt(DateTime lastSeenAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeviceOut(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeviceOut(...).copyWith(id: 12, name: "My name")
  /// ````
  DeviceOut call({
    String id,
    String name,
    DevicePlatform platform,
    DateTime lastSeenAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeviceOut.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeviceOut.copyWith.fieldName(...)`
class _$DeviceOutCWProxyImpl implements _$DeviceOutCWProxy {
  const _$DeviceOutCWProxyImpl(this._value);

  final DeviceOut _value;

  @override
  DeviceOut id(String id) => this(id: id);

  @override
  DeviceOut name(String name) => this(name: name);

  @override
  DeviceOut platform(DevicePlatform platform) => this(platform: platform);

  @override
  DeviceOut lastSeenAt(DateTime lastSeenAt) => this(lastSeenAt: lastSeenAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeviceOut(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeviceOut(...).copyWith(id: 12, name: "My name")
  /// ````
  DeviceOut call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? platform = const $CopyWithPlaceholder(),
    Object? lastSeenAt = const $CopyWithPlaceholder(),
  }) {
    return DeviceOut(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      platform: platform == const $CopyWithPlaceholder()
          ? _value.platform
          // ignore: cast_nullable_to_non_nullable
          : platform as DevicePlatform,
      lastSeenAt: lastSeenAt == const $CopyWithPlaceholder()
          ? _value.lastSeenAt
          // ignore: cast_nullable_to_non_nullable
          : lastSeenAt as DateTime,
    );
  }
}

extension $DeviceOutCopyWith on DeviceOut {
  /// Returns a callable class that can be used as follows: `instanceOfDeviceOut.copyWith(...)` or like so:`instanceOfDeviceOut.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeviceOutCWProxy get copyWith => _$DeviceOutCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceOut _$DeviceOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DeviceOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'name', 'platform', 'last_seen_at'],
      );
      final val = DeviceOut(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecode(_$DevicePlatformEnumMap, v),
        ),
        lastSeenAt: $checkedConvert(
          'last_seen_at',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'lastSeenAt': 'last_seen_at'});

Map<String, dynamic> _$DeviceOutToJson(DeviceOut instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'platform': _$DevicePlatformEnumMap[instance.platform]!,
  'last_seen_at': instance.lastSeenAt.toIso8601String(),
};

const _$DevicePlatformEnumMap = {
  DevicePlatform.ios: 'ios',
  DevicePlatform.android: 'android',
  DevicePlatform.web: 'web',
};
