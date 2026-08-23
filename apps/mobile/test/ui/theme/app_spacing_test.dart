import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/ui/theme/app_spacing.dart';

void main() {
  test('spacing tokens strictly increase and stay on a 4px grid', () {
    const values = [
      AppSpacing.xs,
      AppSpacing.sm,
      AppSpacing.md,
      AppSpacing.lg,
      AppSpacing.xl,
      AppSpacing.xxl,
    ];

    for (final value in values) {
      expect(value % 4, 0, reason: '$value is not a multiple of the 4px base unit.');
    }

    for (var i = 1; i < values.length; i++) {
      expect(values[i], greaterThan(values[i - 1]));
    }
  });
}
