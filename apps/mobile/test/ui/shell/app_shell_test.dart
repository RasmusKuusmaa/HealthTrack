import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:healthtrack/core/connectivity_provider.dart';
import 'package:healthtrack/l10n/app_localizations.dart';
import 'package:healthtrack/ui/shell/app_shell.dart';

/// A minimal router exercising [AppShell] on its own, independent of the
/// full app router — a [StatefulNavigationShell] can only be constructed by
/// go_router itself, so this is the smallest setup that gives us one.
GoRouter _testRouter() {
  return GoRouter(
    initialLocation: '/a',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/a',
                builder: (context, state) => const Text('Tab A'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/b',
                builder: (context, state) => const Text('Tab B'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/c',
                builder: (context, state) => const Text('Tab C'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/d',
                builder: (context, state) => const Text('Tab D'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Future<void> _pumpShell(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: _testRouter(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows all four destinations with the first tab active', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await _pumpShell(tester, container);

    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Log'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Tab A'), findsOneWidget);
  });

  testWidgets('tapping a destination switches the visible branch', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await _pumpShell(tester, container);

    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();

    expect(find.text('Tab C'), findsOneWidget);
    expect(find.text('Tab A'), findsNothing);
  });

  testWidgets('switching away and back preserves branch state', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await _pumpShell(tester, container);

    await tester.tap(find.text('Log'));
    await tester.pumpAndSettle();
    expect(find.text('Tab B'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Tab A'), findsOneWidget);

    await tester.tap(find.text('Log'));
    await tester.pumpAndSettle();
    expect(find.text('Tab B'), findsOneWidget);
  });

  testWidgets('shows the offline banner above the active tab when offline', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [isOnlineProvider.overrideWith((ref) => Stream.value(false))],
    );
    addTearDown(container.dispose);
    await _pumpShell(tester, container);

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.text('Tab A'), findsOneWidget);
  });

  testWidgets('shows no offline banner while online', (tester) async {
    final container = ProviderContainer(
      overrides: [isOnlineProvider.overrideWith((ref) => Stream.value(true))],
    );
    addTearDown(container.dispose);
    await _pumpShell(tester, container);

    expect(find.byIcon(Icons.cloud_off), findsNothing);
  });
}
