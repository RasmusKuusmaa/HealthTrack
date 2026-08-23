import 'package:flutter/material.dart';

/// The app's type scale, built on the platform default font (Roboto on
/// Android, San Francisco on iOS) so there's no bundled font asset to
/// license or ship. Named after Material 3's roles; values are deliberately
/// explicit rather than left to `Typography`'s defaults, so the scale is a
/// single, readable source of truth screens can be checked against.
abstract final class AppTypography {
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, height: 1.12, fontWeight: FontWeight.w400),
    displayMedium: TextStyle(fontSize: 45, height: 1.16, fontWeight: FontWeight.w400),
    displaySmall: TextStyle(fontSize: 36, height: 1.22, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontSize: 32, height: 1.25, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(fontSize: 28, height: 1.29, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 24, height: 1.33, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22, height: 1.27, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: 1.43,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.43,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.33,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 1.43,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 1.33,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 1.45,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );
}
