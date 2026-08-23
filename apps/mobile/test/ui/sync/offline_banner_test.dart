import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/core/connectivity_provider.dart';
import 'package:healthtrack/ui/sync/offline_banner.dart';

void main() {
  testWidgets('shows nothing while online', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [isOnlineProvider.overrideWith((ref) => Stream.value(true))],
        child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.cloud_off), findsNothing);
    expect(find.textContaining('Offline'), findsNothing);
  });

  testWidgets('shows the offline message while offline', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isOnlineProvider.overrideWith((ref) => Stream.value(false)),
        ],
        child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.textContaining('Offline'), findsOneWidget);
  });

  testWidgets('shows nothing while connectivity is still loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isOnlineProvider.overrideWith((ref) => const Stream<bool>.empty()),
        ],
        child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.cloud_off), findsNothing);
  });
}
