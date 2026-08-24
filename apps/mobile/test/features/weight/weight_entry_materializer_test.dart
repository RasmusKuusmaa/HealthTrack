import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/local/app_database.dart';
import 'package:healthtrack/features/weight/weight_entry_materializer.dart';

void main() {
  late AppDatabase db;
  late WeightEntryMaterializer materializer;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    materializer = WeightEntryMaterializer(db);
  });

  tearDown(() => db.close());

  test('creates a row with only the given fields set', () async {
    await materializer.applyCreateOrUpdate(
      entityId: 'entry-1',
      userId: 'user-1',
      fields: {
        'logged_at_utc': '2026-01-01T08:00:00Z',
        'local_date': '2026-01-01',
        'tz_offset_minutes': 120,
        'weight_kg': 82.5,
        'source': 'manual',
      },
    );

    final row = await (db.select(
      db.weightEntries,
    )..where((t) => t.id.equals('entry-1'))).getSingle();
    expect(row.userId, 'user-1');
    expect(row.loggedAtUtc, DateTime.parse('2026-01-01T08:00:00Z'));
    expect(row.localDate, DateTime.utc(2026, 1, 1));
    expect(row.tzOffsetMinutes, 120);
    expect(row.weightKg, 82.5);
    expect(row.source, 'manual');
    expect(row.note, isNull);
  });

  test('an update only touches the fields it carries', () async {
    await materializer.applyCreateOrUpdate(
      entityId: 'entry-1',
      userId: 'user-1',
      fields: {'weight_kg': 82.5, 'note': 'before'},
    );
    await materializer.applyCreateOrUpdate(
      entityId: 'entry-1',
      userId: 'user-1',
      fields: {'weight_kg': 81.9},
    );

    final row = await (db.select(
      db.weightEntries,
    )..where((t) => t.id.equals('entry-1'))).getSingle();
    expect(row.weightKg, 81.9);
    expect(row.note, 'before');
  });

  test('a user can have multiple weight entries', () async {
    await materializer.applyCreateOrUpdate(
      entityId: 'entry-1',
      userId: 'user-1',
      fields: {'weight_kg': 80.0},
    );
    await materializer.applyCreateOrUpdate(
      entityId: 'entry-2',
      userId: 'user-1',
      fields: {'weight_kg': 79.8},
    );

    final rows = await (db.select(
      db.weightEntries,
    )..where((t) => t.userId.equals('user-1'))).get();
    expect(rows, hasLength(2));
  });

  test('applyDelete sets deleted_at without clearing other fields', () async {
    await materializer.applyCreateOrUpdate(
      entityId: 'entry-1',
      userId: 'user-1',
      fields: {'weight_kg': 80.0},
    );
    final deletedAt = DateTime.utc(2026, 1, 1);

    await materializer.applyDelete(entityId: 'entry-1', deletedAt: deletedAt);

    final row = await (db.select(
      db.weightEntries,
    )..where((t) => t.id.equals('entry-1'))).getSingle();
    expect(row.weightKg, 80.0);
    expect(row.deletedAt, deletedAt);
  });
}
