//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'totp_confirm_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TotpConfirmResponse {
  /// Returns a new [TotpConfirmResponse] instance.
  TotpConfirmResponse({

    required  this.recoveryCodes,
  });

  @JsonKey(
    
    name: r'recovery_codes',
    required: true,
    includeIfNull: false,
  )


  final List<String> recoveryCodes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TotpConfirmResponse &&
      other.recoveryCodes == recoveryCodes;

    @override
    int get hashCode =>
        recoveryCodes.hashCode;

  factory TotpConfirmResponse.fromJson(Map<String, dynamic> json) => _$TotpConfirmResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TotpConfirmResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

