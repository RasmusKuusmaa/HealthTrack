//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'revert_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RevertRequest {
  /// Returns a new [RevertRequest] instance.
  RevertRequest({

    required  this.targetServerSeq,

    required  this.deviceId,
  });

  @JsonKey(
    
    name: r'target_server_seq',
    required: true,
    includeIfNull: false,
  )


  final int targetServerSeq;



  @JsonKey(
    
    name: r'device_id',
    required: true,
    includeIfNull: false,
  )


  final String deviceId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RevertRequest &&
      other.targetServerSeq == targetServerSeq &&
      other.deviceId == deviceId;

    @override
    int get hashCode =>
        targetServerSeq.hashCode +
        deviceId.hashCode;

  factory RevertRequest.fromJson(Map<String, dynamic> json) => _$RevertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RevertRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

