//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'totp_enroll_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TotpEnrollResponse {
  /// Returns a new [TotpEnrollResponse] instance.
  TotpEnrollResponse({

    required  this.provisioningUri,

    required  this.qrCodePngBase64,
  });

  @JsonKey(
    
    name: r'provisioning_uri',
    required: true,
    includeIfNull: false,
  )


  final String provisioningUri;



  @JsonKey(
    
    name: r'qr_code_png_base64',
    required: true,
    includeIfNull: false,
  )


  final String qrCodePngBase64;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TotpEnrollResponse &&
      other.provisioningUri == provisioningUri &&
      other.qrCodePngBase64 == qrCodePngBase64;

    @override
    int get hashCode =>
        provisioningUri.hashCode +
        qrCodePngBase64.hashCode;

  factory TotpEnrollResponse.fromJson(Map<String, dynamic> json) => _$TotpEnrollResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TotpEnrollResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

