import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/ui/theme/app_typography.dart';

void main() {
  test('each track (display, headline, title, body, label) shrinks from large to small', () {
    final scale = AppTypography.textTheme;
    final tracks = {
      'display': [scale.displayLarge, scale.displayMedium, scale.displaySmall],
      'headline': [scale.headlineLarge, scale.headlineMedium, scale.headlineSmall],
      'title': [scale.titleLarge, scale.titleMedium, scale.titleSmall],
      'body': [scale.bodyLarge, scale.bodyMedium, scale.bodySmall],
      'label': [scale.labelLarge, scale.labelMedium, scale.labelSmall],
    };

    for (final entry in tracks.entries) {
      final sizes = entry.value.map((s) => s!.fontSize!).toList();
      for (var i = 1; i < sizes.length; i++) {
        expect(
          sizes[i],
          lessThan(sizes[i - 1]),
          reason:
              '${entry.key} step $i (${sizes[i]}) should be smaller than step '
              '${i - 1} (${sizes[i - 1]}).',
        );
      }
    }
  });

  test('every style in the scale defines a font size', () {
    final scale = AppTypography.textTheme;
    for (final style in [
      scale.displayLarge,
      scale.displayMedium,
      scale.displaySmall,
      scale.headlineLarge,
      scale.headlineMedium,
      scale.headlineSmall,
      scale.titleLarge,
      scale.titleMedium,
      scale.titleSmall,
      scale.bodyLarge,
      scale.bodyMedium,
      scale.bodySmall,
      scale.labelLarge,
      scale.labelMedium,
      scale.labelSmall,
    ]) {
      expect(style, isNotNull);
      expect(style!.fontSize, isNotNull);
    }
  });
}
