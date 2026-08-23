// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_confirm.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PasswordResetConfirmCWProxy {
  PasswordResetConfirm token(String token);

  PasswordResetConfirm newPassword(String newPassword);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PasswordResetConfirm(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PasswordResetConfirm(...).copyWith(id: 12, name: "My name")
  /// ````
  PasswordResetConfirm call({String token, String newPassword});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPasswordResetConfirm.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPasswordResetConfirm.copyWith.fieldName(...)`
class _$PasswordResetConfirmCWProxyImpl
    implements _$PasswordResetConfirmCWProxy {
  const _$PasswordResetConfirmCWProxyImpl(this._value);

  final PasswordResetConfirm _value;

  @override
  PasswordResetConfirm token(String token) => this(token: token);

  @override
  PasswordResetConfirm newPassword(String newPassword) =>
      this(newPassword: newPassword);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PasswordResetConfirm(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PasswordResetConfirm(...).copyWith(id: 12, name: "My name")
  /// ````
  PasswordResetConfirm call({
    Object? token = const $CopyWithPlaceholder(),
    Object? newPassword = const $CopyWithPlaceholder(),
  }) {
    return PasswordResetConfirm(
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
      newPassword: newPassword == const $CopyWithPlaceholder()
          ? _value.newPassword
          // ignore: cast_nullable_to_non_nullable
          : newPassword as String,
    );
  }
}

extension $PasswordResetConfirmCopyWith on PasswordResetConfirm {
  /// Returns a callable class that can be used as follows: `instanceOfPasswordResetConfirm.copyWith(...)` or like so:`instanceOfPasswordResetConfirm.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PasswordResetConfirmCWProxy get copyWith =>
      _$PasswordResetConfirmCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordResetConfirm _$PasswordResetConfirmFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PasswordResetConfirm', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['token', 'new_password']);
  final val = PasswordResetConfirm(
    token: $checkedConvert('token', (v) => v as String),
    newPassword: $checkedConvert('new_password', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'newPassword': 'new_password'});

Map<String, dynamic> _$PasswordResetConfirmToJson(
  PasswordResetConfirm instance,
) => <String, dynamic>{
  'token': instance.token,
  'new_password': instance.newPassword,
};
