import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/ui/widgets/app_empty_state.dart';

void main() {
  testWidgets('shows the message and default icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppEmptyState(message: 'No entries yet')),
      ),
    );

    expect(find.text('No entries yet'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('shows a custom icon and an action when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppEmptyState(
            message: 'No workouts yet',
            icon: Icons.fitness_center,
            action: const Text('Log a workout'),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    expect(find.text('Log a workout'), findsOneWidget);
  });

  testWidgets('shows no action by default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppEmptyState(message: 'No entries yet')),
      ),
    );

    final column = tester.widget<Column>(find.byType(Column));
    expect(column.children, hasLength(3));
  });
}
