import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/sync/sync_status_provider.dart';
import 'package:healthtrack/ui/sync/sync_status_indicator.dart';

void main() {
  testWidgets('shows nothing when idle', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SyncStatusIndicator())),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.cloud_done), findsNothing);
    expect(find.byIcon(Icons.cloud_off), findsNothing);
  });

  testWidgets('shows a spinner while syncing', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SyncStatusIndicator())),
      ),
    );

    container.read(syncStatusControllerProvider.notifier).markSyncing();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a done icon once synced', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SyncStatusIndicator())),
      ),
    );

    container.read(syncStatusControllerProvider.notifier).markSynced();
    await tester.pump();

    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
  });

  testWidgets('shows an error icon with the message in a tooltip', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SyncStatusIndicator())),
      ),
    );

    container.read(syncStatusControllerProvider.notifier).markError('network unreachable');
    await tester.pump();

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
    expect(tooltip.message, 'network unreachable');
  });
}
