import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state_provider.g.dart';

/// Placeholder auth state until 4.18 (secure token storage) and 4.21 (auth
/// screens) land — the router only needs to know whether to send someone to
/// the sign-in screen or into the app shell.
@riverpod
class IsAuthenticated extends _$IsAuthenticated {
  @override
  bool build() => false;

  void signIn() => state = true;

  void signOut() => state = false;
}
