import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_providers.dart';
import '../../core/router.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/widgets/app_error_state.dart';
import '../../ui/widgets/app_primary_button.dart';

enum _VerifyStatus { verifying, success, error }

/// Reached via the deep link in the verification email
/// (`/verify-email?token=...`); verifies automatically on open.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({required this.token, super.key});

  final String? token;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  _VerifyStatus _status = _VerifyStatus.verifying;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    final token = widget.token;
    if (token == null || token.isEmpty) {
      setState(() => _status = _VerifyStatus.error);
      return;
    }

    try {
      final repository = await ref.read(authRepositoryProvider.future);
      await repository.verifyEmail(token);
      if (mounted) setState(() => _status = _VerifyStatus.success);
    } catch (_) {
      if (mounted) setState(() => _status = _VerifyStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email')),
      body: switch (_status) {
        _VerifyStatus.verifying => const Center(
          child: CircularProgressIndicator(),
        ),
        _VerifyStatus.success => _buildSuccess(context),
        _VerifyStatus.error => AppErrorState(
          message: 'This verification link is invalid or has expired.',
          onRetry: _verify,
        ),
      },
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Your email is verified.', textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Sign in',
            onPressed: () => context.go(loginPath),
          ),
        ],
      ),
    );
  }
}
