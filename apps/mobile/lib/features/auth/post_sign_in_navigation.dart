import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_state_provider.dart';
import '../../core/router.dart';
import '../profile/profile_providers.dart';
import '../profile/user_profile_repository.dart';

/// Called once `POST /auth/login` has actually succeeded (tokens saved).
/// Loads the profile — bootstrapping it if this is the first sign-in on
/// this device — then marks the app authenticated and routes to onboarding
/// or the shell depending on whether the profile is complete. Order
/// matters: the completeness check runs before `signIn()` so there's no
/// flash of the shell before redirecting to onboarding.
Future<void> navigateAfterSignIn(BuildContext context, WidgetRef ref) async {
  final profileRepository = await ref.read(
    userProfileRepositoryProvider.future,
  );
  final profile = await profileRepository.ensureLoaded();

  if (!context.mounted) return;
  ref.read(isAuthenticatedProvider.notifier).signIn();

  if (isOnboardingComplete(profile)) {
    context.go(homePath);
  } else {
    context.go(onboardingPath);
  }
}
