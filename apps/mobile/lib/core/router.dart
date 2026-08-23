import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/verify_email_screen.dart';
import '../ui/placeholder_screen.dart';
import '../ui/shell/app_shell.dart';
import 'auth/auth_state_provider.dart';

const loginPath = '/login';
const registerPath = '/register';
const verifyEmailPath = '/verify-email';
const mfaChallengePath = '/mfa-challenge';
const homePath = '/home';
const logPath = '/log';
const progressPath = '/progress';
const settingsPath = '/settings';

/// Routes reachable before signing in. An authenticated user is redirected
/// away from these into the shell; an unauthenticated user is redirected
/// into one of these (login) from everywhere else.
const _publicPaths = {
  loginPath,
  registerPath,
  verifyEmailPath,
  mfaChallengePath,
};

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
      final isPublicRoute = _publicPaths.contains(state.matchedLocation);

      if (!isAuthenticated && !isPublicRoute) return loginPath;
      if (isAuthenticated && isPublicRoute) return homePath;
      return null;
    },
    routes: [
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: registerPath,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: verifyEmailPath,
        builder: (context, state) =>
            VerifyEmailScreen(token: state.uri.queryParameters['token']),
      ),
      GoRoute(
        path: mfaChallengePath,
        builder: (context, state) =>
            const PlaceholderScreen(title: "Verify it's you"),
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
