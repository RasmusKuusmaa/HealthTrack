import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/ui/widgets/app_primary_button.dart';

void main() {
  testWidgets('shows the label and calls onPressed when tapped', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPrimaryButton(label: 'Save', onPressed: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.byType(AppPrimaryButton));
    expect(tapped, isTrue);
  });

  testWidgets('shows a spinner and disables the button while loading', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPrimaryButton(
            label: 'Save',
            onPressed: () => tapped = true,
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.text('Save'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    await tester.tap(find.byType(AppPrimaryButton), warnIfMissed: false);
    expect(tapped, isFalse);
  });
}
