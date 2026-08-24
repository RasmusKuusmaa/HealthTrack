import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/local/app_database.dart';
import 'package:healthtrack/data/local/op_writer.dart';
import 'package:healthtrack/features/weight/weight_entry_materializer.dart';
import 'package:healthtrack/features/weight/weight_repository.dart';
import 'package:healthtrack/sync/entity_registry.dart';
import 'package:healthtrack/sync/entity_writer.dart';
import 'package:healthtrack/sync/local_materializer.dart';

void main() {
  late AppDatabase db;
  late WeightRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final registry = EntityRegistry()
      ..register('weight_entry', WeightEntryMaterializer(db));
    final materializer = LocalMaterializer(db, registry);
    final opWriter = OpWriter(db, userId: 'user-1', deviceId: 'device-1');
    repository = WeightRepository(
      db: db,
      entityWriter: EntityWriter(db, opWriter, materializer),
      userId: 'user-1',
    );
  });

  tearDown(() => db.close());

  test('create writes a new entry with a fresh id', () async {
    final entityId = await repository.create({
      'logged_at_utc': '2026-01-01T08:00:00Z',
      'local_date': '2026-01-01',
      'tz_offset_minutes': 0,
      'weight_kg': 82.5,
      'source': 'manual',
    });

    final row = await (db.select(
      db.weightEntries,
    )..where((t) => t.id.equals(entityId))).getSingle();
    expect(row.weightKg, 82.5);
  });

  test('update only touches the given fields', () async {
    final entityId = await repository.create({
      'weight_kg': 82.5,
      'note': 'before',
    });

    await repository.update(entityId, {'weight_kg': 81.9});

    final row = await (db.select(
      db.weightEntries,
    )..where((t) => t.id.equals(entityId))).getSingle();
    expect(row.weightKg, 81.9);
    expect(row.note, 'before');
  });

  test('delete tombstones the entry and excludes it from watchAll', () async {
    final entityId = await repository.create({
      'local_date': '2026-01-01',
      'weight_kg': 82.5,
    });

    await repository.delete(entityId);

    final row = await (db.select(
      db.weightEntries,
    )..where((t) => t.id.equals(entityId))).getSingle();
    expect(row.deletedAt, isNotNull);
    expect(await repository.watchAll().first, isEmpty);
  });

  test('watchAll returns non-deleted entries newest first', () async {
    await repository.create({'local_date': '2026-01-01', 'weight_kg': 80.0});
    await repository.create({'local_date': '2026-01-05', 'weight_kg': 79.5});

    final entries = await repository.watchAll().first;

    expect(entries, hasLength(2));
    expect(entries.first.localDate, DateTime.utc(2026, 1, 5));
    expect(entries.last.localDate, DateTime.utc(2026, 1, 1));
  });
}
