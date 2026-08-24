import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/features/weight/weight_entry_payload.dart';

void main() {
  test('fills logged_at_utc, local_date, and tz_offset_minutes from now', () {
    final nowLocal = DateTime(2026, 3, 15, 8, 30);

    final payload = buildWeightEntryPayload(weightKg: 82.5, nowLocal: nowLocal);

    expect(payload['weight_kg'], 82.5);
    expect(payload['source'], 'manual');
    expect(payload['local_date'], '2026-03-15');
    expect(payload['tz_offset_minutes'], nowLocal.timeZoneOffset.inMinutes);
    expect(
      DateTime.parse(payload['logged_at_utc'] as String),
      nowLocal.toUtc(),
    );
    expect(payload.containsKey('note'), isFalse);
  });

  test('includes a non-empty note', () {
    final payload = buildWeightEntryPayload(
      weightKg: 70.0,
      note: 'after breakfast',
      nowLocal: DateTime(2026, 1, 1),
    );

    expect(payload['note'], 'after breakfast');
  });

  test('omits an empty note', () {
    final payload = buildWeightEntryPayload(
      weightKg: 70.0,
      note: '',
      nowLocal: DateTime(2026, 1, 1),
    );

    expect(payload.containsKey('note'), isFalse);
  });

  test('pads single-digit month and day in local_date', () {
    final payload = buildWeightEntryPayload(
      weightKg: 70.0,
      nowLocal: DateTime(2026, 1, 5),
    );

    expect(payload['local_date'], '2026-01-05');
  });
}
