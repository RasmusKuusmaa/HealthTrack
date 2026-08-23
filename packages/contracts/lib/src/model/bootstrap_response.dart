//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bootstrap_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BootstrapResponse {
  /// Returns a new [BootstrapResponse] instance.
  BootstrapResponse({

    required  this.entities,

    required  this.cursor,
  });

  @JsonKey(
    
    name: r'entities',
    required: true,
    includeIfNull: false,
  )


  final Map<String, List<Map<String, Object>>> entities;



  @JsonKey(
    
    name: r'cursor',
    required: true,
    includeIfNull: false,
  )


  final int cursor;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BootstrapResponse &&
      other.entities == entities &&
      other.cursor == cursor;

    @override
    int get hashCode =>
        entities.hashCode +
        cursor.hashCode;

  factory BootstrapResponse.fromJson(Map<String, dynamic> json) => _$BootstrapResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BootstrapResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

