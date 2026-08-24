import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/local/app_database.dart';
import 'package:healthtrack/data/local/op_writer.dart';
import 'package:healthtrack/features/weight/weight_entry_materializer.dart';
import 'package:healthtrack/features/weight/weight_logging_screen.dart';
import 'package:healthtrack/features/weight/weight_providers.dart';
import 'package:healthtrack/features/weight/weight_repository.dart';
import 'package:healthtrack/features/weight/weight_unit_conversion.dart';
import 'package:healthtrack/features/profile/profile_providers.dart';
import 'package:healthtrack/l10n/app_localizations.dart';
import 'package:healthtrack/sync/entity_registry.dart';
import 'package:healthtrack/sync/entity_writer.dart';
import 'package:healthtrack/sync/local_materializer.dart';

void main() {
  testWidgets('entering a weight and saving persists it and clears the form', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final registry = EntityRegistry()
      ..register('weight_entry', WeightEntryMaterializer(db));
    final materializer = LocalMaterializer(db, registry);
    final opWriter = OpWriter(db, userId: 'user-1', deviceId: 'device-1');
    final repository = WeightRepository(
      db: db,
      entityWriter: EntityWriter(db, opWriter, materializer),
      userId: 'user-1',
    );

    final container = ProviderContainer(
      overrides: [
        weightRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WeightLoggingScreen(),
        ),
      ),
    );

    final saveButton = find.widgetWithText(FilledButton, 'Save');
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);

    await tester.enterText(find.widgetWithText(TextField, 'Weight'), '82.5');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Weight logged'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Weight'), findsOneWidget);
    final weightField = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Weight'),
    );
    expect(weightField.controller!.text, isEmpty);

    final rows = await db.select(db.weightEntries).get();
    expect(rows, hasLength(1));
    expect(rows.single.weightKg, 82.5);
  });

  testWidgets('entering a value in lb converts it to kg before saving', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final registry = EntityRegistry()
      ..register('weight_entry', WeightEntryMaterializer(db));
    final materializer = LocalMaterializer(db, registry);
    final opWriter = OpWriter(db, userId: 'user-1', deviceId: 'device-1');
    final repository = WeightRepository(
      db: db,
      entityWriter: EntityWriter(db, opWriter, materializer),
      userId: 'user-1',
    );

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
          home: const WeightLoggingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Weight'), findsOneWidget);
    final weightField = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Weight'),
    );
    expect(weightField.decoration!.suffixText, 'lb');

    await tester.enterText(find.widgetWithText(TextField, 'Weight'), '100');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final rows = await db.select(db.weightEntries).get();
    expect(rows, hasLength(1));
    expect(rows.single.weightKg, closeTo(lbToKg(100), 0.0000001));
  });

  testWidgets('save stays disabled for a zero or blank weight', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WeightLoggingScreen(),
        ),
      ),
    );

    final saveButton = find.widgetWithText(FilledButton, 'Save');
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);

    await tester.enterText(find.widgetWithText(TextField, 'Weight'), '0');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);
  });
}
