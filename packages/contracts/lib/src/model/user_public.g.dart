// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_public.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UserPublicCWProxy {
  UserPublic id(String id);

  UserPublic email(String email);

  UserPublic displayName(String displayName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UserPublic(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UserPublic(...).copyWith(id: 12, name: "My name")
  /// ````
  UserPublic call({String id, String email, String displayName});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUserPublic.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUserPublic.copyWith.fieldName(...)`
class _$UserPublicCWProxyImpl implements _$UserPublicCWProxy {
  const _$UserPublicCWProxyImpl(this._value);

  final UserPublic _value;

  @override
  UserPublic id(String id) => this(id: id);

  @override
  UserPublic email(String email) => this(email: email);

  @override
  UserPublic displayName(String displayName) => this(displayName: displayName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UserPublic(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UserPublic(...).copyWith(id: 12, name: "My name")
  /// ````
  UserPublic call({
    Object? id = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
  }) {
    return UserPublic(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String,
    );
  }
}

extension $UserPublicCopyWith on UserPublic {
  /// Returns a callable class that can be used as follows: `instanceOfUserPublic.copyWith(...)` or like so:`instanceOfUserPublic.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UserPublicCWProxy get copyWith => _$UserPublicCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPublic _$UserPublicFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UserPublic', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'email', 'display_name']);
      final val = UserPublic(
        id: $checkedConvert('id', (v) => v as String),
        email: $checkedConvert('email', (v) => v as String),
        displayName: $checkedConvert('display_name', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'displayName': 'display_name'});

Map<String, dynamic> _$UserPublicToJson(UserPublic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'display_name': instance.displayName,
    };
