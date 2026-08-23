import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/sync/sync_trigger_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late int triggerCount;
  late StreamController<List<ConnectivityResult>> connectivity;
  late void Function(Timer)? capturedPeriodicCallback;
  late SyncTriggerController controller;

  setUp(() {
    triggerCount = 0;
    connectivity = StreamController<List<ConnectivityResult>>.broadcast();
    capturedPeriodicCallback = null;
    controller = SyncTriggerController(
      onTrigger: () async {
        triggerCount++;
      },
      connectivityStream: connectivity.stream,
      timerFactory: (period, callback) {
        capturedPeriodicCallback = callback;
        return Timer(const Duration(days: 9999), () {});
      },
    );
  });

  tearDown(() {
    controller.dispose();
    connectivity.close();
  });

  test('fires when the app resumes from the background', () {
    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(triggerCount, 1);
  });

  test('does not fire on other lifecycle transitions', () {
    controller.didChangeAppLifecycleState(AppLifecycleState.paused);
    controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
    controller.didChangeAppLifecycleState(AppLifecycleState.detached);
    expect(triggerCount, 0);
  });

  test('fires when connectivity transitions from offline to online', () {
    controller.handleConnectivityChange([ConnectivityResult.none]);
    expect(triggerCount, 0);

    controller.handleConnectivityChange([ConnectivityResult.wifi]);
    expect(triggerCount, 1);
  });

  test('does not fire when already online and switching networks', () {
    controller.handleConnectivityChange([ConnectivityResult.wifi]);
    expect(triggerCount, 0);

    controller.handleConnectivityChange([ConnectivityResult.mobile]);
    expect(triggerCount, 0);
  });

  test('does not fire going from online to offline', () {
    controller.handleConnectivityChange([ConnectivityResult.wifi]);
    controller.handleConnectivityChange([ConnectivityResult.none]);
    expect(triggerCount, 0);
  });

  test('start() wires up the periodic timer via the injected factory', () {
    controller.start();
    expect(capturedPeriodicCallback, isNotNull);

    capturedPeriodicCallback!(Timer(Duration.zero, () {}));
    expect(triggerCount, 1);
  });

  test('start() subscribes to the connectivity stream', () async {
    controller.start();

    connectivity.add([ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);
    connectivity.add([ConnectivityResult.wifi]);
    await Future<void>.delayed(Duration.zero);

    expect(triggerCount, 1);
  });
}
