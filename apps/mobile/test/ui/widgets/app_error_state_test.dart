import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/ui/widgets/app_error_state.dart';

void main() {
  testWidgets('shows the message and no retry button by default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppErrorState(message: 'Something went wrong')),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('shows a retry button that calls onRetry when tapped', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppErrorState(
            message: 'Something went wrong',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });
}
