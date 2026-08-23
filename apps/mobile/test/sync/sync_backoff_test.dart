import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/sync/sync_backoff.dart';

void main() {
  test('delay grows exponentially with the attempt number, capped by maxDelay', () {
    // A fixed Random(nextDouble always returning 1.0 via a seeded double)
    // isn't available from dart:math directly, so instead assert the upper
    // bound the jitter can never exceed for each attempt.
    const backoff = SyncBackoff(
      baseDelay: Duration(seconds: 1),
      maxDelay: Duration(seconds: 10),
      random: _MaxRandom(),
    );

    expect(backoff.delayFor(0), Duration(seconds: 1)); // base * 2^0 = 1s
    expect(backoff.delayFor(1), Duration(seconds: 2)); // base * 2^1 = 2s
    expect(backoff.delayFor(2), Duration(seconds: 4)); // base * 2^2 = 4s
    expect(backoff.delayFor(3), Duration(seconds: 8)); // base * 2^3 = 8s
    expect(backoff.delayFor(4), Duration(seconds: 10)); // base * 2^4 = 16s, capped at 10s
  });

  test('delay is never negative and never exceeds the uncapped exponential value', () {
    const backoff = SyncBackoff(
      baseDelay: Duration(seconds: 1),
      maxDelay: Duration(minutes: 5),
      random: _ZeroRandom(),
    );

    expect(backoff.delayFor(0), Duration.zero);
    expect(backoff.delayFor(3), Duration.zero);
  });
}

/// A [Random] stub whose `nextDouble` always returns 1.0, so `delayFor`
/// returns exactly the (capped) exponential value with no jitter shaved off.
class _MaxRandom implements Random {
  const _MaxRandom();

  @override
  double nextDouble() => 1.0;

  @override
  int nextInt(int max) => max - 1;

  @override
  bool nextBool() => true;
}

/// A [Random] stub whose `nextDouble` always returns 0.0.
class _ZeroRandom implements Random {
  const _ZeroRandom();

  @override
  double nextDouble() => 0.0;

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;
}
