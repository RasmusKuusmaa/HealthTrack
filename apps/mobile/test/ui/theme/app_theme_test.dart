import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/ui/theme/app_theme.dart';
import 'package:healthtrack/ui/theme/app_typography.dart';

void main() {
  test('light and dark themes have the matching brightness', () {
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });

  test('light and dark themes are generated from the same seed color', () {
    // ColorScheme.fromSeed derives every role from the seed's hue, so the
    // two brightness variants should agree on the seed's own primary hue
    // family even though the exact shades differ.
    expect(AppTheme.light.colorScheme.primary, isNot(AppTheme.dark.colorScheme.primary));
    expect(HSLColor.fromColor(AppTheme.light.colorScheme.primary).hue, closeTo(HSLColor.fromColor(AppTheme.dark.colorScheme.primary).hue, 15));
  });

  test('both themes use the shared type scale', () {
    expect(AppTheme.light.textTheme.bodyMedium?.fontSize, AppTypography.textTheme.bodyMedium?.fontSize);
    expect(AppTheme.dark.textTheme.bodyMedium?.fontSize, AppTypography.textTheme.bodyMedium?.fontSize);
  });

  test('Material 3 is enabled', () {
    expect(AppTheme.light.useMaterial3, isTrue);
    expect(AppTheme.dark.useMaterial3, isTrue);
  });
}
