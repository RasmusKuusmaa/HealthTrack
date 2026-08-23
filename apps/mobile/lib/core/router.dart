import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ui/placeholder_screen.dart';
import '../ui/shell/app_shell.dart';
import 'auth/auth_state_provider.dart';

const loginPath = '/login';
const homePath = '/home';
const logPath = '/log';
const progressPath = '/progress';
const settingsPath = '/settings';

/// Notifies go_router to re-run [GoRouter.redirect] whenever
/// [isAuthenticatedProvider] changes, since `GoRouter` only re-evaluates
/// redirects on navigation or when its `refreshListenable` fires.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(isAuthenticatedProvider, (previous, next) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: homePath,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final goingToLogin = state.matchedLocation == loginPath;

      if (!isAuthenticated && !goingToLogin) return loginPath;
      if (isAuthenticated && goingToLogin) return homePath;
      return null;
    },
    routes: [
      GoRoute(
        path: loginPath,
        builder: (context, state) => const PlaceholderScreen(title: 'Sign in'),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: homePath,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Home'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: logPath,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Log'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: progressPath,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Progress'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: settingsPath,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Settings'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
