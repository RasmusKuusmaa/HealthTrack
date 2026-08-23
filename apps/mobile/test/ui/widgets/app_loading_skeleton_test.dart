import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/ui/widgets/app_loading_skeleton.dart';

void main() {
  testWidgets('renders a container with the requested size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLoadingSkeleton(width: 120, height: 20, borderRadius: 4),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    expect(container.constraints?.maxWidth, 120);
    expect(container.constraints?.maxHeight, 20);
  });

  testWidgets('pulses: opacity changes as the animation runs', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppLoadingSkeleton())),
    );

    final opacityAt = <double>[];
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      opacityAt.add(tester.widget<Opacity>(find.byType(Opacity)).opacity);
    }

    expect(opacityAt.toSet().length, greaterThan(1));
  });
}
