import 'package:healthtrack_api_client/src/model/bootstrap_response.dart';
import 'package:healthtrack_api_client/src/model/device_out.dart';
import 'package:healthtrack_api_client/src/model/entity_history_entry.dart';
import 'package:healthtrack_api_client/src/model/entity_history_response.dart';
import 'package:healthtrack_api_client/src/model/http_validation_error.dart';
import 'package:healthtrack_api_client/src/model/login_request.dart';
import 'package:healthtrack_api_client/src/model/logout_request.dart';
import 'package:healthtrack_api_client/src/model/mfa_required_response.dart';
import 'package:healthtrack_api_client/src/model/password_reset_confirm.dart';
import 'package:healthtrack_api_client/src/model/password_reset_request.dart';
import 'package:healthtrack_api_client/src/model/pull_response.dart';
import 'package:healthtrack_api_client/src/model/pulled_op.dart';
import 'package:healthtrack_api_client/src/model/push_op_request.dart';
import 'package:healthtrack_api_client/src/model/push_op_result.dart';
import 'package:healthtrack_api_client/src/model/push_request.dart';
import 'package:healthtrack_api_client/src/model/push_response.dart';
import 'package:healthtrack_api_client/src/model/refresh_request.dart';
import 'package:healthtrack_api_client/src/model/register_request.dart';
import 'package:healthtrack_api_client/src/model/response_login_auth_login_post.dart';
import 'package:healthtrack_api_client/src/model/revert_request.dart';
import 'package:healthtrack_api_client/src/model/token_pair.dart';
import 'package:healthtrack_api_client/src/model/totp_confirm_request.dart';
import 'package:healthtrack_api_client/src/model/totp_confirm_response.dart';
import 'package:healthtrack_api_client/src/model/totp_enroll_response.dart';
import 'package:healthtrack_api_client/src/model/user_public.dart';
import 'package:healthtrack_api_client/src/model/validation_error.dart';
import 'package:healthtrack_api_client/src/model/verify_email_request.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
      switch (targetType) {
        case 'String':
          return '$value' as ReturnType;
        case 'int':
          return (value is int ? value : int.parse('$value')) as ReturnType;
        case 'bool':
          if (value is bool) {
            return value as ReturnType;
          }
          final valueString = '$value'.toLowerCase();
          return (valueString == 'true' || valueString == '1') as ReturnType;
        case 'double':
          return (value is double ? value : double.parse('$value')) as ReturnType;
        case 'BootstrapResponse':
          return BootstrapResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeviceOut':
          return DeviceOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DevicePlatform':
          
          
        case 'EntityHistoryEntry':
          return EntityHistoryEntry.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EntityHistoryResponse':
          return EntityHistoryResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HTTPValidationError':
          return HTTPValidationError.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LoginRequest':
          return LoginRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogoutRequest':
          return LogoutRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MfaRequiredResponse':
          return MfaRequiredResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OpType':
          
          
        case 'PasswordResetConfirm':
          return PasswordResetConfirm.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PasswordResetRequest':
          return PasswordResetRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PullResponse':
          return PullResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PulledOp':
          return PulledOp.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PushOpRequest':
          return PushOpRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PushOpResult':
          return PushOpResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PushRequest':
          return PushRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PushResponse':
          return PushResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RefreshRequest':
          return RefreshRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RegisterRequest':
          return RegisterRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ResponseLoginAuthLoginPost':
          return ResponseLoginAuthLoginPost.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RevertRequest':
          return RevertRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TokenPair':
          return TokenPair.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TotpConfirmRequest':
          return TotpConfirmRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TotpConfirmResponse':
          return TotpConfirmResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TotpEnrollResponse':
          return TotpEnrollResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UserPublic':
          return UserPublic.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ValidationError':
          return ValidationError.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'VerifyEmailRequest':
          return VerifyEmailRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!.trim(); // ignore: parameter_assignments
            return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    }
    throw Exception('Cannot deserialize');
  }