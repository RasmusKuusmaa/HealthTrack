import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Installs process-wide error handling: framework build/layout/paint
/// errors, uncaught async errors outside the framework's own zone, and a
/// friendly full-screen fallback in place of Flutter's default red error
/// screen. Call once, before [runApp].
void configureGlobalErrorHandling() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _reportError(details.exception, details.stack ?? StackTrace.empty);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    _reportError(error, stack);
    return true;
  };

  ErrorWidget.builder = (details) => AppCrashScreen(error: details.exception);
}

/// Runs [body] inside a zone that also reports errors it doesn't rethrow
/// past — the counterpart to [PlatformDispatcher.instance.onError] for
/// errors that occur before the platform dispatcher is listening, or in
/// code that doesn't run through it.
void runGuarded(void Function() body) {
  runZonedGuarded(body, (error, stack) => _reportError(error, stack));
}

void _reportError(Object error, StackTrace stack) {
  // Crash reporting is opt-in and lands in a later phase (20.12); until
  // then, this at least guarantees an error is never silently swallowed.
  debugPrint('Unhandled error: $error\n$stack');
}

/// The fallback shown by [ErrorWidget.builder]. Deliberately doesn't depend
/// on this app's theme, providers, or localization — it has to render
/// correctly even if one of those is the reason something else broke.
class AppCrashScreen extends StatelessWidget {
  const AppCrashScreen({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong.',
                    style: TextStyle(fontSize: 18),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 8),
                    Text(
                      '$error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
