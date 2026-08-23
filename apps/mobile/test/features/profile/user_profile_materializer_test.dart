import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/local/app_database.dart';
import 'package:healthtrack/features/profile/user_profile_materializer.dart';

void main() {
  late AppDatabase db;
  late UserProfileMaterializer materializer;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    materializer = UserProfileMaterializer(db);
  });

  tearDown(() => db.close());

  test('creates a row with only the given fields set', () async {
    await materializer.applyCreateOrUpdate(
      entityId: 'user-1',
      userId: 'user-1',
      fields: {'display_name': 'Ada', 'timezone': 'Europe/Tallinn'},
    );

    final row = await (db.select(
      db.userProfiles,
    )..where((t) => t.id.equals('user-1'))).getSingle();
    expect(row.displayName, 'Ada');
    expect(row.timezone, 'Europe/Tallinn');
    expect(row.heightCm, isNull);
    expect(row.unitSystem, 'metric');
  });

  test('an update only touches the fields it carries', () async {
    await materializer.applyCreateOrUpdate(
      entityId: 'user-1',
      userId: 'user-1',
      fields: {'display_name': 'Ada', 'height_cm': 170.0},
    );
    await materializer.applyCreateOrUpdate(
      entityId: 'user-1',
      userId: 'user-1',
      fields: {'height_cm': 172.5},
    );

    final row = await (db.select(
      db.userProfiles,
    )..where((t) => t.id.equals('user-1'))).getSingle();
    expect(row.displayName, 'Ada');
    expect(row.heightCm, 172.5);
  });

  test('parses birth_date into a DateTime', () async {
    await materializer.applyCreateOrUpdate(
      entityId: 'user-1',
      userId: 'user-1',
      fields: {'birth_date': '1990-05-15'},
    );

    final row = await (db.select(
      db.userProfiles,
    )..where((t) => t.id.equals('user-1'))).getSingle();
    expect(row.birthDate, DateTime.utc(1990, 5, 15));
  });

  test('applyDelete sets deleted_at without clearing other fields', () async {
    await materializer.applyCreateOrUpdate(
      entityId: 'user-1',
      userId: 'user-1',
      fields: {'display_name': 'Ada'},
    );
    final deletedAt = DateTime.utc(2026, 1, 1);

    await materializer.applyDelete(entityId: 'user-1', deletedAt: deletedAt);

    final row = await (db.select(
      db.userProfiles,
    )..where((t) => t.id.equals('user-1'))).getSingle();
    expect(row.displayName, 'Ada');
    expect(row.deletedAt, deletedAt);
  });
}
