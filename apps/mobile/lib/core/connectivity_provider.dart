import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// Whether the device currently has any network connectivity. Feeds the
/// offline banner and sync status indicator (4.14) and the sync connectivity
/// trigger (4.12).
@riverpod
Stream<bool> isOnline(Ref ref) {
  return Connectivity().onConnectivityChanged.map(hasConnectivity);
}

bool hasConnectivity(List<ConnectivityResult> results) =>
    results.any((result) => result != ConnectivityResult.none);
