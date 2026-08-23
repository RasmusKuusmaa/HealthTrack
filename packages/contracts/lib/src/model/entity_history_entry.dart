//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:healthtrack_api_client/src/model/op_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entity_history_entry.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EntityHistoryEntry {
  /// Returns a new [EntityHistoryEntry] instance.
  EntityHistoryEntry({

    required  this.serverSeq,

    required  this.opType,

    required  this.payload,

    required  this.deviceId,

    required  this.clientTs,

    required  this.serverTs,
  });

  @JsonKey(
    
    name: r'server_seq',
    required: true,
    includeIfNull: false,
  )


  final int serverSeq;



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



  @JsonKey(
    
    name: r'server_ts',
    required: true,
    includeIfNull: false,
  )


  final DateTime serverTs;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EntityHistoryEntry &&
      other.serverSeq == serverSeq &&
      other.opType == opType &&
      other.payload == payload &&
      other.deviceId == deviceId &&
      other.clientTs == clientTs &&
      other.serverTs == serverTs;

    @override
    int get hashCode =>
        serverSeq.hashCode +
        opType.hashCode +
        payload.hashCode +
        deviceId.hashCode +
        clientTs.hashCode +
        serverTs.hashCode;

  factory EntityHistoryEntry.fromJson(Map<String, dynamic> json) => _$EntityHistoryEntryFromJson(json);

  Map<String, dynamic> toJson() => _$EntityHistoryEntryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

