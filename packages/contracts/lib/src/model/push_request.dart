//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:healthtrack_api_client/src/model/push_op_request.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'push_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PushRequest {
  /// Returns a new [PushRequest] instance.
  PushRequest({

    required  this.ops,
  });

  @JsonKey(
    
    name: r'ops',
    required: true,
    includeIfNull: false,
  )


  final List<PushOpRequest> ops;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PushRequest &&
      other.ops == ops;

    @override
    int get hashCode =>
        ops.hashCode;

  factory PushRequest.fromJson(Map<String, dynamic> json) => _$PushRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PushRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

