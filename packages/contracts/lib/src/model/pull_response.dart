//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:healthtrack_api_client/src/model/pulled_op.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pull_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PullResponse {
  /// Returns a new [PullResponse] instance.
  PullResponse({

    required  this.ops,

    required  this.nextCursor,
  });

  @JsonKey(
    
    name: r'ops',
    required: true,
    includeIfNull: false,
  )


  final List<PulledOp> ops;



  @JsonKey(
    
    name: r'next_cursor',
    required: true,
    includeIfNull: false,
  )


  final int nextCursor;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PullResponse &&
      other.ops == ops &&
      other.nextCursor == nextCursor;

    @override
    int get hashCode =>
        ops.hashCode +
        nextCursor.hashCode;

  factory PullResponse.fromJson(Map<String, dynamic> json) => _$PullResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PullResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

