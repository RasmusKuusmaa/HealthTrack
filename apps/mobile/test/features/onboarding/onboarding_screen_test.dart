import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/core/auth/auth_state_provider.dart';
import 'package:healthtrack/core/network/api_providers.dart';
import 'package:healthtrack/core/router.dart';
import 'package:healthtrack/data/local/app_database.dart';
import 'package:healthtrack/data/local/op_writer.dart';
import 'package:healthtrack/data/secure/secure_key_value_store.dart';
import 'package:healthtrack/features/profile/profile_providers.dart';
import 'package:healthtrack/features/profile/user_profile_materializer.dart';
import 'package:healthtrack/features/profile/user_profile_repository.dart';
import 'package:healthtrack/sync/entity_registry.dart';
import 'package:healthtrack/sync/entity_writer.dart';
import 'package:healthtrack/sync/local_materializer.dart';
import 'package:healthtrack/sync/sync_api.dart';
import 'package:healthtrack/sync/sync_cursor_store.dart';
import 'package:healthtrack/sync/sync_engine.dart';

class _InMemorySecureStore implements SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

class _EmptySyncApi implements SyncApi {
  @override
  Future<List<PushOpResult>> push(List<PushOpRequest> ops) async => const [];

  @override
  Future<PullPage> pull({required int since, int? limit}) async {
    return const PullPage(ops: [], nextCursor: 0);
  }

  @override
  Future<BootstrapSnapshot> bootstrap() async {
    return const BootstrapSnapshot(entities: {}, cursor: 0);
  }
}

void main() {
  testWidgets('completing every step saves the profile and enters the shell', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final registry = EntityRegistry()
      ..register('user_profile', UserProfileMaterializer(db));
    final materializer = LocalMaterializer(db, registry);
    final opWriter = OpWriter(db, userId: 'user-1', deviceId: 'device-1');
    final syncEngine = SyncEngine(
      db: db,
      api: _EmptySyncApi(),
      cursorStore: SyncCursorStore(_InMemorySecureStore()),
      materializer: materializer,
      registry: registry,
      userId: 'user-1',
    );
    final repository = UserProfileRepository(
      db: db,
      entityWriter: EntityWriter(db, opWriter, materializer),
      syncEngine: syncEngine,
      userId: 'user-1',
    );

    final container = ProviderContainer(
      overrides: [
        userProfileRepositoryProvider.overrideWith((ref) async => repository),
        secureKeyValueStoreProvider.overrideWith(
          (ref) => _InMemorySecureStore(),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(isAuthenticatedProvider.notifier).signIn();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: container.read(appRouterProvider),
        ),
      ),
    );
    container.read(appRouterProvider).go(onboardingPath);
    await tester.pumpAndSettle();

    // Step 1: profile — Continue starts disabled until every field is set.
    expect(tester.widget<FilledButton>(_continueButton()).onPressed, isNull);

    await tester.tap(find.text('Choose birth date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Female'));
    await tester.enterText(find.byType(TextField), '170');
    await tester.pumpAndSettle();

    expect(tester.widget<FilledButton>(_continueButton()).onPressed, isNotNull);
    await tester.tap(_continueButton());
    await tester.pumpAndSettle();

    // Step 2: units — default selection is already valid.
    expect(find.text('Which units do you prefer?'), findsOneWidget);
    await tester.tap(_continueButton());
    await tester.pumpAndSettle();

    // Step 3: timezone — pre-filled with a default, already valid.
    expect(find.widgetWithText(TextField, 'Timezone'), findsOneWidget);
    await tester.tap(_continueButton());
    await tester.pumpAndSettle();

    // Step 4: goals intent.
    expect(find.text('What brings you here?'), findsOneWidget);
    await tester.tap(find.text('Build muscle'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
    await tester.pumpAndSettle();

    expect(find.text('Home — coming soon'), findsOneWidget);

    final saved = await (db.select(
      db.userProfiles,
    )..where((t) => t.id.equals('user-1'))).getSingle();
    expect(saved.sexAtBirth, 'female');
    expect(saved.heightCm, 170.0);
    expect(saved.unitSystem, 'metric');
    expect(saved.timezone, 'UTC');
  });
}

Finder _continueButton() =>
    find.byWidgetPredicate((w) => w is FilledButton).last;
