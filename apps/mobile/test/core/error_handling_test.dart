import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/core/error_handling.dart';

class _ThrowsOnBuild extends StatelessWidget {
  const _ThrowsOnBuild();

  @override
  Widget build(BuildContext context) {
    throw StateError('boom');
  }
}

void main() {
  test(
    'installs handlers for framework, platform, and widget-build errors',
    () {
      final originalFlutterOnError = FlutterError.onError;
      final originalPlatformOnError = PlatformDispatcher.instance.onError;
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      addTearDown(() {
        FlutterError.onError = originalFlutterOnError;
        PlatformDispatcher.instance.onError = originalPlatformOnError;
        ErrorWidget.builder = originalErrorWidgetBuilder;
      });

      configureGlobalErrorHandling();

      expect(FlutterError.onError, isNot(same(originalFlutterOnError)));
      expect(
        PlatformDispatcher.instance.onError,
        isNot(same(originalPlatformOnError)),
      );
      expect(ErrorWidget.builder, isNot(same(originalErrorWidgetBuilder)));
    },
  );

  testWidgets('a widget that throws during build shows AppCrashScreen', (
    tester,
  ) async {
    final originalErrorWidgetBuilder = ErrorWidget.builder;
    addTearDown(() => ErrorWidget.builder = originalErrorWidgetBuilder);

    configureGlobalErrorHandling();

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: _ThrowsOnBuild())),
    );

    expect(find.byType(AppCrashScreen), findsOneWidget);
    expect(find.text('Something went wrong.'), findsOneWidget);
  });

  testWidgets('AppCrashScreen shows the error detail in debug mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: AppCrashScreen(error: StateError('specific reason'))),
    );

    expect(find.textContaining('specific reason'), findsOneWidget);
  });

  test('runGuarded catches a synchronous throw without propagating it', () {
    var ran = false;

    expect(() {
      runGuarded(() {
        ran = true;
        throw StateError('boom');
      });
    }, returnsNormally);

    expect(ran, isTrue);
  });
}
