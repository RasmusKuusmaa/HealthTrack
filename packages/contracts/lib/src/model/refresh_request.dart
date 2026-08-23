//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'refresh_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RefreshRequest {
  /// Returns a new [RefreshRequest] instance.
  RefreshRequest({

    required  this.refreshToken,

    required  this.deviceId,
  });

  @JsonKey(
    
    name: r'refresh_token',
    required: true,
    includeIfNull: false,
  )


  final String refreshToken;



  @JsonKey(
    
    name: r'device_id',
    required: true,
    includeIfNull: false,
  )


  final String deviceId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RefreshRequest &&
      other.refreshToken == refreshToken &&
      other.deviceId == deviceId;

    @override
    int get hashCode =>
        refreshToken.hashCode +
        deviceId.hashCode;

  factory RefreshRequest.fromJson(Map<String, dynamic> json) => _$RefreshRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

