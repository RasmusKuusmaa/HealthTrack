import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/sync/retrying_sync_runner.dart';
import 'package:healthtrack/sync/sync_backoff.dart';

void main() {
  test('succeeds on the first attempt without waiting', () async {
    var calls = 0;
    final waits = <Duration>[];
    final runner = RetryingSyncRunner(
      sync: () async {
        calls++;
      },
      onWait: (d) async => waits.add(d),
    );

    await runner.run();

    expect(calls, 1);
    expect(waits, isEmpty);
  });

  test('retries after a failure and succeeds once it stops failing', () async {
    var calls = 0;
    final waits = <Duration>[];
    final runner = RetryingSyncRunner(
      sync: () async {
        calls++;
        if (calls < 3) throw Exception('transient failure');
      },
      backoff: const SyncBackoff(maxAttempts: 5),
      onWait: (d) async => waits.add(d),
    );

    await runner.run();

    expect(calls, 3);
    expect(waits, hasLength(2));
  });

  test('gives up after maxAttempts and throws SyncRetryExhausted', () async {
    var calls = 0;
    final runner = RetryingSyncRunner(
      sync: () async {
        calls++;
        throw Exception('always fails');
      },
      backoff: const SyncBackoff(maxAttempts: 3),
      onWait: (d) async {},
    );

    await expectLater(runner.run(), throwsA(isA<SyncRetryExhausted>()));
    expect(calls, 3);
  });

  test('SyncRetryExhausted carries the attempt count and last error', () async {
    final runner = RetryingSyncRunner(
      sync: () async => throw Exception('boom'),
      backoff: const SyncBackoff(maxAttempts: 2),
      onWait: (d) async {},
    );

    try {
      await runner.run();
      fail('expected SyncRetryExhausted');
    } on SyncRetryExhausted catch (e) {
      expect(e.attempts, 2);
      expect(e.lastError.toString(), contains('boom'));
    }
  });
}
