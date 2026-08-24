/// Builds a `weight_entry` create payload for [weightKg] logged right now.
/// [nowLocal] defaults to the device's current time; passing it explicitly
/// keeps this deterministic for tests.
Map<String, dynamic> buildWeightEntryPayload({
  required double weightKg,
  String? note,
  DateTime? nowLocal,
}) {
  final local = nowLocal ?? DateTime.now();
  final payload = <String, dynamic>{
    'logged_at_utc': local.toUtc().toIso8601String(),
    'local_date': _isoDate(local),
    'tz_offset_minutes': local.timeZoneOffset.inMinutes,
    'weight_kg': weightKg,
    'source': 'manual',
  };
  if (note != null && note.isNotEmpty) payload['note'] = note;
  return payload;
}

String _isoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
