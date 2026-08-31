import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/local/app_database.dart';
import 'package:healthtrack/data/local/op_writer.dart';
import 'package:healthtrack/features/profile/profile_providers.dart';
import 'package:healthtrack/features/weight/weight_entry_materializer.dart';
import 'package:healthtrack/features/weight/weight_history_screen.dart';
import 'package:healthtrack/features/weight/weight_providers.dart';
import 'package:healthtrack/features/weight/weight_repository.dart';
import 'package:healthtrack/l10n/app_localizations.dart';
import 'package:healthtrack/sync/entity_registry.dart';
import 'package:healthtrack/sync/entity_writer.dart';
import 'package:healthtrack/sync/local_materializer.dart';

/// Replaces the pumped widget tree so [WeightHistoryScreen]'s StreamBuilder
/// disposes now, then pumps again so drift's zero-duration close-debounce
/// timer resolves before the test returns — otherwise flutter_test's
/// automatic teardown disposes the tree itself (scheduling that same timer
/// too late) and fails on "A Timer is still pending".
Future<void> disposeAndFlushTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 1));
}

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

  testWidgets('shows an empty state when there are no entries', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        weightRepositoryProvider.overrideWith((ref) async => repository),
        currentUnitSystemProvider.overrideWith((ref) => Stream.value(null)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WeightHistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No weight entries yet. Log your first one.'), findsOneWidget);

    await disposeAndFlushTimers(tester);
  });

  testWidgets('lists entries with their weight in the preferred unit', (
    tester,
  ) async {
    await repository.create({
      'local_date': '2026-01-01',
      'weight_kg': 80.0,
      'note': 'morning',
    });

    final container = ProviderContainer(
      overrides: [
        weightRepositoryProvider.overrideWith((ref) async => repository),
        currentUnitSystemProvider.overrideWith(
          (ref) => Stream.value('metric'),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WeightHistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2026-01-01'), findsOneWidget);
    expect(find.text('80.0 kg'), findsOneWidget);
    expect(find.text('morning'), findsOneWidget);

    await disposeAndFlushTimers(tester);
  });

  testWidgets('editing an entry updates only the changed fields', (
    tester,
  ) async {
    final entityId = await repository.create({
      'local_date': '2026-01-01',
      'weight_kg': 80.0,
      'note': 'morning',
    });

    final container = ProviderContainer(
      overrides: [
        weightRepositoryProvider.overrideWith((ref) async => repository),
        currentUnitSystemProvider.overrideWith(
          (ref) => Stream.value('metric'),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WeightHistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('80.0 kg'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Weight'), '79.5');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final row = await (db.select(
      db.weightEntries,
    )..where((t) => t.id.equals(entityId))).getSingle();
    expect(row.weightKg, 79.5);
    expect(row.note, 'morning');

    await disposeAndFlushTimers(tester);
  });

  testWidgets('swiping an entry away deletes it', (tester) async {
    final entityId = await repository.create({
      'local_date': '2026-01-01',
      'weight_kg': 80.0,
    });

    final container = ProviderContainer(
      overrides: [
        weightRepositoryProvider.overrideWith((ref) async => repository),
        currentUnitSystemProvider.overrideWith(
          (ref) => Stream.value('metric'),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WeightHistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.text('80.0 kg'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    final row = await (db.select(
      db.weightEntries,
    )..where((t) => t.id.equals(entityId))).getSingle();
    expect(row.deletedAt, isNotNull);
    expect(find.text('80.0 kg'), findsNothing);

    await disposeAndFlushTimers(tester);
  });

  testWidgets('shows weight converted to lb when the unit is imperial', (
    tester,
  ) async {
    await repository.create({'local_date': '2026-01-01', 'weight_kg': 80.0});

    final container = ProviderContainer(
      overrides: [
        weightRepositoryProvider.overrideWith((ref) async => repository),
        currentUnitSystemProvider.overrideWith(
          (ref) => Stream.value('imperial'),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WeightHistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('176.4 lb'), findsOneWidget);

    await disposeAndFlushTimers(tester);
  });
}
