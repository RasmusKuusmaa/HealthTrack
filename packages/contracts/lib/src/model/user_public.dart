//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_public.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserPublic {
  /// Returns a new [UserPublic] instance.
  UserPublic({

    required  this.id,

    required  this.email,

    required  this.displayName,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



  @JsonKey(
    
    name: r'display_name',
    required: true,
    includeIfNull: false,
  )


  final String displayName;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UserPublic &&
      other.id == id &&
      other.email == email &&
      other.displayName == displayName;

    @override
    int get hashCode =>
        id.hashCode +
        email.hashCode +
        displayName.hashCode;

  factory UserPublic.fromJson(Map<String, dynamic> json) => _$UserPublicFromJson(json);

  Map<String, dynamic> toJson() => _$UserPublicToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

