//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'totp_confirm_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TotpConfirmRequest {
  /// Returns a new [TotpConfirmRequest] instance.
  TotpConfirmRequest({

    required  this.code,
  });

  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TotpConfirmRequest &&
      other.code == code;

    @override
    int get hashCode =>
        code.hashCode;

  factory TotpConfirmRequest.fromJson(Map<String, dynamic> json) => _$TotpConfirmRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TotpConfirmRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

