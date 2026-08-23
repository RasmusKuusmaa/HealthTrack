// ignore_for_file: prefer_initializing_formals
import 'sync_backoff.dart';

class SyncRetryExhausted implements Exception {
  SyncRetryExhausted(this.attempts, this.lastError);

  final int attempts;
  final Object lastError;

  @override
  String toString() =>
      'SyncRetryExhausted after $attempts attempt(s): $lastError';
}

/// Retries a sync action with exponential backoff and jitter, giving up
/// after [SyncBackoff.maxAttempts] attempts. Takes the sync action itself
/// (typically `syncEngine.sync`) rather than a `SyncEngine`, so it isn't
/// coupled to that class's shape.
class RetryingSyncRunner {
  RetryingSyncRunner({
    required Future<void> Function() sync,
    this.backoff = const SyncBackoff(),
    Future<void> Function(Duration)? onWait,
  }) : _sync = sync,
       _onWait = onWait ?? ((d) => Future<void>.delayed(d));

  final Future<void> Function() _sync;
  final SyncBackoff backoff;
  final Future<void> Function(Duration) _onWait;

  /// Runs the sync action, retrying on failure until it succeeds or
  /// [SyncBackoff.maxAttempts] attempts have been made — in which case the
  /// last error is thrown wrapped in [SyncRetryExhausted].
  Future<void> run() async {
    var attempt = 0;
    while (true) {
      try {
        await _sync();
        return;
      } catch (error) {
        attempt++;
        if (attempt >= backoff.maxAttempts) {
          throw SyncRetryExhausted(attempt, error);
        }
        await _onWait(backoff.delayFor(attempt - 1));
      }
    }
  }
}
