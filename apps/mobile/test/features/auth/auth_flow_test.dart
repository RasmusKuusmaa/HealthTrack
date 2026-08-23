import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
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
import 'package:healthtrack/data/secure/token_store.dart';
import 'package:healthtrack/features/auth/auth_repository.dart';
import 'package:healthtrack/features/profile/profile_providers.dart';
import 'package:healthtrack/l10n/app_localizations.dart';
import 'package:healthtrack/features/profile/user_profile_materializer.dart';
import 'package:healthtrack/features/profile/user_profile_repository.dart';
import 'package:healthtrack/sync/entity_registry.dart';
import 'package:healthtrack/sync/entity_writer.dart';
import 'package:healthtrack/sync/local_materializer.dart';
import 'package:healthtrack/sync/sync_api.dart';
import 'package:healthtrack/sync/sync_cursor_store.dart';
import 'package:healthtrack/sync/sync_engine.dart';
import 'package:healthtrack_api_client/healthtrack_api_client.dart'
    show AuthApi;

class _InMemorySecureStore implements SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

class _FakeSyncApi implements SyncApi {
  _FakeSyncApi(this.bootstrapSnapshot);

  final BootstrapSnapshot bootstrapSnapshot;

  @override
  Future<List<PushOpResult>> push(List<PushOpRequest> ops) async => const [];

  @override
  Future<PullPage> pull({required int since, int? limit}) async {
    return const PullPage(ops: [], nextCursor: 0);
  }

  @override
  Future<BootstrapSnapshot> bootstrap() async => bootstrapSnapshot;
}

/// A [UserProfileRepository] whose first `ensureLoaded()` bootstraps from
/// [bootstrapSnapshot] — empty by default, so login lands on onboarding
/// unless a test supplies a snapshot with a complete profile.
UserProfileRepository _profileRepository({
  BootstrapSnapshot bootstrapSnapshot = const BootstrapSnapshot(
    entities: {},
    cursor: 0,
  ),
}) {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final registry = EntityRegistry()
    ..register('user_profile', UserProfileMaterializer(db));
  final materializer = LocalMaterializer(db, registry);
  final opWriter = OpWriter(db, userId: 'user-1', deviceId: 'device-1');
  final syncEngine = SyncEngine(
    db: db,
    api: _FakeSyncApi(bootstrapSnapshot),
    cursorStore: SyncCursorStore(_InMemorySecureStore()),
    materializer: materializer,
    registry: registry,
    userId: 'user-1',
  );
  return UserProfileRepository(
    db: db,
    entityWriter: EntityWriter(db, opWriter, materializer),
    syncEngine: syncEngine,
    userId: 'user-1',
  );
}

const _completeProfileSnapshot = BootstrapSnapshot(
  entities: {
    'user_profile': [
      {
        'id': 'user-1',
        'display_name': 'Ada',
        'birth_date': '1990-01-01',
        'sex_at_birth': 'female',
        'height_cm': 170.0,
      },
    ],
  },
  cursor: 1,
);

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._responses);

  final Map<String, ResponseBody Function(RequestOptions options)> _responses;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final handler = _responses[options.path];
    if (handler == null) {
      throw StateError('No scripted response for ${options.path}');
    }
    return handler(options);
  }
}

ResponseBody _json(int statusCode, Object body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

AuthRepository _repositoryWith(
  Map<String, ResponseBody Function(RequestOptions)> responses,
) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
    ..httpClientAdapter = _ScriptedAdapter(responses);
  return AuthRepository(
    dio: dio,
    authApi: AuthApi(dio),
    tokenStore: TokenStore(_InMemorySecureStore()),
    deviceId: 'device-1',
  );
}

Future<ProviderContainer> _pumpApp(
  WidgetTester tester,
  AuthRepository repository, {
  BootstrapSnapshot? profileSnapshot,
}) async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWith((ref) async => repository),
      userProfileRepositoryProvider.overrideWith(
        (ref) async => profileSnapshot == null
            ? _profileRepository()
            : _profileRepository(bootstrapSnapshot: profileSnapshot),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: container.read(appRouterProvider),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets(
    'successful login with an incomplete profile goes to onboarding',
    (tester) async {
      await _pumpApp(
        tester,
        _repositoryWith({
          '/auth/login': (_) => _json(200, {
            'access_token': 'access-1',
            'refresh_token': 'refresh-1',
            'token_type': 'bearer',
            'expires_in': 900,
          }),
        }),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'a@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(AppBar, 'Set up your profile'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'successful login with an already-complete profile goes to the shell',
    (tester) async {
      await _pumpApp(
        tester,
        _repositoryWith({
          '/auth/login': (_) => _json(200, {
            'access_token': 'access-1',
            'refresh_token': 'refresh-1',
            'token_type': 'bearer',
            'expires_in': 900,
          }),
        }),
        profileSnapshot: _completeProfileSnapshot,
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'a@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Home — coming soon'), findsOneWidget);
    },
  );

  testWidgets('a failed login shows an error and stays on the sign-in screen', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      _repositoryWith({
        '/auth/login': (_) => _json(401, {'detail': 'invalid credentials'}),
      }),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'a@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Sign in'), findsOneWidget);
    expect(find.textContaining('Could not sign in'), findsOneWidget);
  });

  testWidgets('a login requiring MFA navigates to the challenge screen', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      _repositoryWith({
        '/auth/login': (_) => _json(200, {'mfa_required': true}),
      }),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'a@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, "Verify it's you"), findsOneWidget);
  });

  testWidgets(
    'submitting an empty form shows validation errors without a network call',
    (tester) async {
      await _pumpApp(
        tester,
        _repositoryWith({
          '/auth/login': (_) => throw StateError('should not be called'),
        }),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
    },
  );

  testWidgets(
    'registering successfully shows the check-your-email confirmation',
    (tester) async {
      await _pumpApp(
        tester,
        _repositoryWith({
          '/auth/register': (_) => _json(200, {
            'id': 'user-1',
            'email': 'a@example.com',
            'display_name': 'Ada',
          }),
        }),
      );

      await tester.tap(find.text("Don't have an account? Register"));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Ada');
      await tester.enterText(find.byType(TextFormField).at(1), 'a@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining("We've sent a verification link"),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'opening the verify-email link with a valid token shows success',
    (tester) async {
      final repository = _repositoryWith({
        '/auth/verify-email': (_) => _json(200, {'verified': true}),
      });
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: container.read(appRouterProvider),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      container.read(appRouterProvider).go('$verifyEmailPath?token=abc123');
      await tester.pumpAndSettle();

      expect(find.text('Your email is verified.'), findsOneWidget);
    },
  );

  testWidgets('opening the verify-email link without a token shows an error', (
    tester,
  ) async {
    final repository = _repositoryWith({});
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: container.read(appRouterProvider),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    container.read(appRouterProvider).go(verifyEmailPath);
    await tester.pumpAndSettle();

    expect(
      find.text('This verification link is invalid or has expired.'),
      findsOneWidget,
    );
  });

  testWidgets('a valid MFA code after a challenge signs the user in', (
    tester,
  ) async {
    var loginCalls = 0;
    await _pumpApp(
      tester,
      _repositoryWith({
        '/auth/login': (options) {
          loginCalls++;
          final body = options.data as Map<String, dynamic>;
          if (loginCalls == 1) return _json(200, {'mfa_required': true});
          expect(body['totp_code'], '123456');
          return _json(200, {
            'access_token': 'access-1',
            'refresh_token': 'refresh-1',
            'token_type': 'bearer',
            'expires_in': 900,
          });
        },
      }),
      profileSnapshot: _completeProfileSnapshot,
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'a@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
    await tester.pumpAndSettle();

    expect(find.text('Home — coming soon'), findsOneWidget);
    expect(loginCalls, 2);
  });

  testWidgets('a rejected MFA code shows an error and stays on the challenge', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      _repositoryWith({
        '/auth/login': (_) => _json(200, {'mfa_required': true}),
      }),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'a@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '000000');
    await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, "Verify it's you"), findsOneWidget);
    expect(find.textContaining('was not accepted'), findsOneWidget);
  });

  testWidgets(
    'switching to a recovery code sends recovery_code instead of totp_code',
    (tester) async {
      await _pumpApp(
        tester,
        _repositoryWith({
          '/auth/login': (options) {
            final body = options.data as Map<String, dynamic>;
            if (body.containsKey('recovery_code')) {
              expect(body['recovery_code'], 'abc-def-ghi');
              expect(body.containsKey('totp_code'), isFalse);
              return _json(200, {
                'access_token': 'access-1',
                'refresh_token': 'refresh-1',
                'token_type': 'bearer',
                'expires_in': 900,
              });
            }
            return _json(200, {'mfa_required': true});
          },
        }),
        profileSnapshot: _completeProfileSnapshot,
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'a@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Use a recovery code instead'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'abc-def-ghi');
      await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
      await tester.pumpAndSettle();

      expect(find.text('Home — coming soon'), findsOneWidget);
    },
  );

  testWidgets(
    'enrolling in MFA shows the QR code, confirms, and shows recovery codes',
    (tester) async {
      final repository = _repositoryWith({
        '/auth/mfa/totp/enroll': (_) => _json(200, {
          'provisioning_uri': 'otpauth://totp/HealthTrack:a@example.com',
          // A minimal 1x1 transparent PNG, base64-encoded.
          'qr_code_png_base64': 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        }),
        '/auth/mfa/totp/confirm': (_) => _json(200, {
          'recovery_codes': ['code-1', 'code-2'],
        }),
      });
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);
      container.read(isAuthenticatedProvider.notifier).signIn();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: container.read(appRouterProvider),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      container.read(appRouterProvider).go(mfaEnrollmentPath);
      await tester.pumpAndSettle();

      expect(
        find.text('Scan this QR code with your authenticator app.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('code-1'), findsOneWidget);
      expect(find.text('code-2'), findsOneWidget);
    },
  );
}
