import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/entity_field_versions_table.dart';
import 'tables/operations_table.dart';
import 'tables/user_profiles_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Operations, EntityFieldVersions, UserProfiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.connection) : super();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'healthtrack.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
