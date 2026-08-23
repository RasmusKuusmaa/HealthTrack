//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:healthtrack_api_client/src/model/device_platform.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LoginRequest {
  /// Returns a new [LoginRequest] instance.
  LoginRequest({

    required  this.email,

    required  this.password,

    required  this.deviceId,

     this.deviceName = 'Unknown device',

     this.platform = DevicePlatform.web,

     this.totpCode,

     this.recoveryCode,
  });

  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



  @JsonKey(
    
    name: r'password',
    required: true,
    includeIfNull: false,
  )


  final String password;



  @JsonKey(
    
    name: r'device_id',
    required: true,
    includeIfNull: false,
  )


  final String deviceId;



  @JsonKey(
    defaultValue: 'Unknown device',
    name: r'device_name',
    required: false,
    includeIfNull: false,
  )


  final String? deviceName;



  @JsonKey(
    defaultValue: DevicePlatform.web,
    name: r'platform',
    required: false,
    includeIfNull: false,
  )


  final DevicePlatform? platform;



  @JsonKey(
    
    name: r'totp_code',
    required: false,
    includeIfNull: false,
  )


  final String? totpCode;



  @JsonKey(
    
    name: r'recovery_code',
    required: false,
    includeIfNull: false,
  )


  final String? recoveryCode;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LoginRequest &&
      other.email == email &&
      other.password == password &&
      other.deviceId == deviceId &&
      other.deviceName == deviceName &&
      other.platform == platform &&
      other.totpCode == totpCode &&
      other.recoveryCode == recoveryCode;

    @override
    int get hashCode =>
        email.hashCode +
        password.hashCode +
        deviceId.hashCode +
        deviceName.hashCode +
        platform.hashCode +
        (totpCode == null ? 0 : totpCode.hashCode) +
        (recoveryCode == null ? 0 : recoveryCode.hashCode);

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

