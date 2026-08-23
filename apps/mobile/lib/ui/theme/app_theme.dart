import 'package:flutter/material.dart';

import 'app_typography.dart';

/// The app's brand seed — a calm teal, fitting a health-tracking app
/// without leaning on any particular clinical or fitness-brand cliché.
const _seedColor = Color(0xFF0B7285);

/// Light and dark [ThemeData], both generated from one seed color so they
/// stay visually consistent, plus the shared type scale ([AppTypography]).
/// See also [AppSpacing] for the spacing tokens screens should use.
abstract final class AppTheme {
  static final ThemeData light = _themeFrom(Brightness.light);
  static final ThemeData dark = _themeFrom(Brightness.dark);

  static ThemeData _themeFrom(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: brightness),
      textTheme: AppTypography.textTheme,
    );
  }
}
