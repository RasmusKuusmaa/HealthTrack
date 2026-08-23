// ignore_for_file: prefer_initializing_formals
import 'dart:math';

/// Full-jitter exponential backoff for sync retries: a random duration
/// between zero and `min(maxDelay, baseDelay * 2^attempt)`, so retrying
/// clients don't all hammer the server in lockstep after a shared outage.
class SyncBackoff {
  const SyncBackoff({
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(minutes: 5),
    this.maxAttempts = 5,
    Random? random,
  }) : _random = random;

  final Duration baseDelay;
  final Duration maxDelay;
  final int maxAttempts;
  final Random? _random;

  /// The delay to wait before retry number [attempt] (zero-based: the delay
  /// before the second overall try is `delayFor(0)`).
  Duration delayFor(int attempt) {
    final scale = pow(2, attempt).toInt();
    final exponential = baseDelay * scale;
    final capped = exponential > maxDelay ? maxDelay : exponential;
    final random = _random ?? Random();
    final jitteredMicros = (random.nextDouble() * capped.inMicroseconds)
        .round();
    return Duration(microseconds: jitteredMicros);
  }
}
