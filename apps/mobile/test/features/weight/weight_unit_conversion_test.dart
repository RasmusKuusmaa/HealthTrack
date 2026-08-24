import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/features/weight/weight_unit_conversion.dart';

void main() {
  test('kgToLb converts using the exact SI pound definition', () {
    expect(kgToLb(1), closeTo(2.2046226, 0.0000001));
  });

  test('lbToKg converts using the exact SI pound definition', () {
    expect(lbToKg(1), closeTo(0.45359237, 0.00000001));
  });

  test('lbToKg and kgToLb round-trip', () {
    const originalKg = 82.5;
    expect(lbToKg(kgToLb(originalKg)), closeTo(originalKg, 0.0000001));
  });

  test('isImperial is true only for the exact string "imperial"', () {
    expect(isImperial('imperial'), isTrue);
    expect(isImperial('metric'), isFalse);
    expect(isImperial(null), isFalse);
  });

  test('unitLabelFor maps metric/null to kg and imperial to lb', () {
    expect(unitLabelFor('metric'), 'kg');
    expect(unitLabelFor(null), 'kg');
    expect(unitLabelFor('imperial'), 'lb');
  });
}
