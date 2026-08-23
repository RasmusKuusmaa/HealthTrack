//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:healthtrack_api_client/src/model/op_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pulled_op.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PulledOp {
  /// Returns a new [PulledOp] instance.
  PulledOp({

    required  this.serverSeq,

    required  this.clientOpId,

    required  this.entityType,

    required  this.entityId,

    required  this.opType,

    required  this.payload,

    required  this.deviceId,

    required  this.clientTs,
  });

  @JsonKey(
    
    name: r'server_seq',
    required: true,
    includeIfNull: false,
  )


  final int serverSeq;



  @JsonKey(
    
    name: r'client_op_id',
    required: true,
    includeIfNull: false,
  )


  final String clientOpId;



  @JsonKey(
    
    name: r'entity_type',
    required: true,
    includeIfNull: false,
  )


  final String entityType;



  @JsonKey(
    
    name: r'entity_id',
    required: true,
    includeIfNull: false,
  )


  final String entityId;



  @JsonKey(
    
    name: r'op_type',
    required: true,
    includeIfNull: false,
  )


  final OpType opType;



  @JsonKey(
    
    name: r'payload',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> payload;



  @JsonKey(
    
    name: r'device_id',
    required: true,
    includeIfNull: false,
  )


  final String deviceId;



  @JsonKey(
    
    name: r'client_ts',
    required: true,
    includeIfNull: false,
  )


  final DateTime clientTs;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PulledOp &&
      other.serverSeq == serverSeq &&
      other.clientOpId == clientOpId &&
      other.entityType == entityType &&
      other.entityId == entityId &&
      other.opType == opType &&
      other.payload == payload &&
      other.deviceId == deviceId &&
      other.clientTs == clientTs;

    @override
    int get hashCode =>
        serverSeq.hashCode +
        clientOpId.hashCode +
        entityType.hashCode +
        entityId.hashCode +
        opType.hashCode +
        payload.hashCode +
        deviceId.hashCode +
        clientTs.hashCode;

  factory PulledOp.fromJson(Map<String, dynamic> json) => _$PulledOpFromJson(json);

  Map<String, dynamic> toJson() => _$PulledOpToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

