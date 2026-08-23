//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:healthtrack_api_client/src/model/mfa_required_response.dart';
import 'package:healthtrack_api_client/src/model/token_pair.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'response_login_auth_login_post.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ResponseLoginAuthLoginPost {
  /// Returns a new [ResponseLoginAuthLoginPost] instance.
  ResponseLoginAuthLoginPost({

    required  this.accessToken,

    required  this.refreshToken,

     this.tokenType = 'bearer',

    required  this.expiresIn,

     this.mfaRequired = true,
  });

  @JsonKey(
    
    name: r'access_token',
    required: true,
    includeIfNull: false,
  )


  final String accessToken;



  @JsonKey(
    
    name: r'refresh_token',
    required: true,
    includeIfNull: false,
  )


  final String refreshToken;



  @JsonKey(
    defaultValue: 'bearer',
    name: r'token_type',
    required: false,
    includeIfNull: false,
  )


  final String? tokenType;



  @JsonKey(
    
    name: r'expires_in',
    required: true,
    includeIfNull: false,
  )


  final int expiresIn;



  @JsonKey(
    defaultValue: true,
    name: r'mfa_required',
    required: false,
    includeIfNull: false,
  )


  final bool? mfaRequired;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ResponseLoginAuthLoginPost &&
      other.accessToken == accessToken &&
      other.refreshToken == refreshToken &&
      other.tokenType == tokenType &&
      other.expiresIn == expiresIn &&
      other.mfaRequired == mfaRequired;

    @override
    int get hashCode =>
        accessToken.hashCode +
        refreshToken.hashCode +
        tokenType.hashCode +
        expiresIn.hashCode +
        mfaRequired.hashCode;

  factory ResponseLoginAuthLoginPost.fromJson(Map<String, dynamic> json) => _$ResponseLoginAuthLoginPostFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseLoginAuthLoginPostToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

