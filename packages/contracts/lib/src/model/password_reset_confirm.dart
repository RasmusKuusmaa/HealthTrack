//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'password_reset_confirm.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PasswordResetConfirm {
  /// Returns a new [PasswordResetConfirm] instance.
  PasswordResetConfirm({

    required  this.token,

    required  this.newPassword,
  });

  @JsonKey(
    
    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



  @JsonKey(
    
    name: r'new_password',
    required: true,
    includeIfNull: false,
  )


  final String newPassword;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PasswordResetConfirm &&
      other.token == token &&
      other.newPassword == newPassword;

    @override
    int get hashCode =>
        token.hashCode +
        newPassword.hashCode;

  factory PasswordResetConfirm.fromJson(Map<String, dynamic> json) => _$PasswordResetConfirmFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordResetConfirmToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

