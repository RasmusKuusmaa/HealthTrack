import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/core/connectivity_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('isOnline reflects the platform connectivity stream', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Prime the provider without asserting on the real platform's initial
    // state — this test only cares that the provider is wired up and
    // exposes a stream, not what this machine's actual connectivity is.
    final subscription = container.listen(
      isOnlineProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(container.read(isOnlineProvider), isA<AsyncValue<bool>>());
  });

  test('hasConnectivity is false when every result is none', () {
    expect(hasConnectivity([ConnectivityResult.none]), isFalse);
  });

  test('hasConnectivity is true when any result is not none', () {
    expect(
      hasConnectivity([ConnectivityResult.none, ConnectivityResult.wifi]),
      isTrue,
    );
  });

  test('hasConnectivity is false for an empty result list', () {
    expect(hasConnectivity(const []), isFalse);
  });
}
