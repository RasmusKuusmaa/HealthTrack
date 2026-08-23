// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

/// Fires a sync whenever the app returns to the foreground, connectivity is
/// regained after being offline, or a periodic timer elapses. Retries and
/// backoff for the sync itself belong to [RetryingSyncRunner] — this class
/// only decides *when* to ask for one.
class SyncTriggerController with WidgetsBindingObserver {
  SyncTriggerController({
    required Future<void> Function() onTrigger,
    Duration periodicInterval = const Duration(minutes: 15),
    Stream<List<ConnectivityResult>>? connectivityStream,
    Timer Function(Duration period, void Function(Timer timer) callback)? timerFactory,
  }) : _onTrigger = onTrigger,
       _periodicInterval = periodicInterval,
       _connectivityStream = connectivityStream ?? Connectivity().onConnectivityChanged,
       _timerFactory = timerFactory ?? Timer.periodic;

  final Future<void> Function() _onTrigger;
  final Duration _periodicInterval;
  final Stream<List<ConnectivityResult>> _connectivityStream;
  final Timer Function(Duration period, void Function(Timer timer) callback) _timerFactory;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _periodicTimer;
  bool _wasOffline = false;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _connectivitySubscription = _connectivityStream.listen(handleConnectivityChange);
    _periodicTimer = _timerFactory(_periodicInterval, (_) => _fire());
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _periodicTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fire();
    }
  }

  /// Fires only on the offline -> online transition, not on every
  /// connectivity event (switching wifi networks shouldn't spam syncs).
  void handleConnectivityChange(List<ConnectivityResult> results) {
    final isOffline = results.every((r) => r == ConnectivityResult.none);
    if (_wasOffline && !isOffline) {
      _fire();
    }
    _wasOffline = isOffline;
  }

  void _fire() {
    unawaited(_onTrigger());
  }
}
