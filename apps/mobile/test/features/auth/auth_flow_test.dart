import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/core/network/api_providers.dart';
import 'package:healthtrack/core/router.dart';
import 'package:healthtrack/data/secure/secure_key_value_store.dart';
import 'package:healthtrack/data/secure/token_store.dart';
import 'package:healthtrack/features/auth/auth_repository.dart';
import 'package:healthtrack_api_client/healthtrack_api_client.dart';

class _InMemorySecureStore implements SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

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
  AuthRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWith((ref) async => repository)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: container.read(appRouterProvider),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('successful login redirects into the app shell', (tester) async {
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

    expect(find.text('Home — coming soon'), findsOneWidget);
  });

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

  testWidgets('a login requiring MFA navigates to the challenge placeholder', (
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

    expect(find.text("Verify it's you — coming soon"), findsOneWidget);
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
}
