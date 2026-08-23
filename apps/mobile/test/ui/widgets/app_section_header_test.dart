import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/ui/widgets/app_section_header.dart';

void main() {
  testWidgets('shows the title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppSectionHeader(title: 'Recent workouts'))),
    );

    expect(find.text('Recent workouts'), findsOneWidget);
  });

  testWidgets('shows a trailing widget when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSectionHeader(
            title: 'Recent workouts',
            trailing: const Text('See all'),
          ),
        ),
      ),
    );

    expect(find.text('See all'), findsOneWidget);
  });

  testWidgets('shows no trailing widget by default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppSectionHeader(title: 'Recent workouts'))),
    );

    final row = tester.widget<Row>(find.byType(Row));
    expect(row.children, hasLength(1));
  });
}
