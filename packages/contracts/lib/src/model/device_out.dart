//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:healthtrack_api_client/src/model/device_platform.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_out.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeviceOut {
  /// Returns a new [DeviceOut] instance.
  DeviceOut({

    required  this.id,

    required  this.name,

    required  this.platform,

    required  this.lastSeenAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'platform',
    required: true,
    includeIfNull: false,
  )


  final DevicePlatform platform;



  @JsonKey(
    
    name: r'last_seen_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime lastSeenAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DeviceOut &&
      other.id == id &&
      other.name == name &&
      other.platform == platform &&
      other.lastSeenAt == lastSeenAt;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        platform.hashCode +
        lastSeenAt.hashCode;

  factory DeviceOut.fromJson(Map<String, dynamic> json) => _$DeviceOutFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

