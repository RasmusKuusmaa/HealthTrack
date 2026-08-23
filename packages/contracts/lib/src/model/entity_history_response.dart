//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:healthtrack_api_client/src/model/entity_history_entry.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entity_history_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EntityHistoryResponse {
  /// Returns a new [EntityHistoryResponse] instance.
  EntityHistoryResponse({

    required  this.history,
  });

  @JsonKey(
    
    name: r'history',
    required: true,
    includeIfNull: false,
  )


  final List<EntityHistoryEntry> history;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EntityHistoryResponse &&
      other.history == history;

    @override
    int get hashCode =>
        history.hashCode;

  factory EntityHistoryResponse.fromJson(Map<String, dynamic> json) => _$EntityHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EntityHistoryResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

