//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mfa_required_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MfaRequiredResponse {
  /// Returns a new [MfaRequiredResponse] instance.
  MfaRequiredResponse({

     this.mfaRequired = true,
  });

  @JsonKey(
    defaultValue: true,
    name: r'mfa_required',
    required: false,
    includeIfNull: false,
  )


  final bool? mfaRequired;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MfaRequiredResponse &&
      other.mfaRequired == mfaRequired;

    @override
    int get hashCode =>
        mfaRequired.hashCode;

  factory MfaRequiredResponse.fromJson(Map<String, dynamic> json) => _$MfaRequiredResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MfaRequiredResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

