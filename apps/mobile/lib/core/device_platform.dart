import 'package:flutter/foundation.dart';
import 'package:healthtrack_api_client/healthtrack_api_client.dart';

/// Maps the running platform to the server's `DevicePlatform` enum, sent on
/// login/register so sessions show up correctly in `GET /auth/sessions`.
DevicePlatform currentDevicePlatform() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return DevicePlatform.ios;
    case TargetPlatform.android:
      return DevicePlatform.android;
    default:
      return DevicePlatform.web;
  }
}
