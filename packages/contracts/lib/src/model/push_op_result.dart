//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'push_op_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PushOpResult {
  /// Returns a new [PushOpResult] instance.
  PushOpResult({

    required  this.clientOpId,

    required  this.serverSeq,
  });

  @JsonKey(
    
    name: r'client_op_id',
    required: true,
    includeIfNull: false,
  )


  final String clientOpId;



  @JsonKey(
    
    name: r'server_seq',
    required: true,
    includeIfNull: false,
  )


  final int serverSeq;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PushOpResult &&
      other.clientOpId == clientOpId &&
      other.serverSeq == serverSeq;

    @override
    int get hashCode =>
        clientOpId.hashCode +
        serverSeq.hashCode;

  factory PushOpResult.fromJson(Map<String, dynamic> json) => _$PushOpResultFromJson(json);

  Map<String, dynamic> toJson() => _$PushOpResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

