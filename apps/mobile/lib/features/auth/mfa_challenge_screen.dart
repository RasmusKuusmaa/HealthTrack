import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/device_platform.dart';
import '../../core/network/api_providers.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/widgets/app_primary_button.dart';
import 'auth_repository.dart';
import 'post_sign_in_navigation.dart';

/// Reached from [LoginScreen] when `/auth/login` reports MFA is required.
/// Re-submits the same credentials plus a TOTP or recovery code.
class MfaChallengeScreen extends ConsumerStatefulWidget {
  const MfaChallengeScreen({required this.credentials, super.key});

  final PendingLoginCredentials credentials;

  @override
  ConsumerState<MfaChallengeScreen> createState() => _MfaChallengeScreenState();
}

class _MfaChallengeScreenState extends ConsumerState<MfaChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _useRecoveryCode = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final repository = await ref.read(authRepositoryProvider.future);
      final outcome = await repository.login(
        email: widget.credentials.email,
        password: widget.credentials.password,
        platform: currentDevicePlatform(),
        totpCode: _useRecoveryCode ? null : _codeController.text.trim(),
        recoveryCode: _useRecoveryCode ? _codeController.text.trim() : null,
      );

      if (!mounted) return;

      if (outcome == LoginOutcome.authenticated) {
        await navigateAfterSignIn(context, ref);
      } else {
        // The server asked for MFA again despite a code being sent — treat
        // it the same as a rejected code rather than looping silently.
        setState(
          () => _errorMessage = 'That code was not accepted. Please try again.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorMessage = 'That code was not accepted. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify it's you")),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _useRecoveryCode
                    ? 'Enter one of your recovery codes.'
                    : 'Enter the 6-digit code from your authenticator app.',
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _codeController,
                keyboardType: _useRecoveryCode
                    ? TextInputType.text
                    : TextInputType.number,
                decoration: InputDecoration(
                  labelText: _useRecoveryCode
                      ? 'Recovery code'
                      : 'Authentication code',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Enter a code'
                    : null,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                label: 'Verify',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => setState(() {
                  _useRecoveryCode = !_useRecoveryCode;
                  _codeController.clear();
                  _errorMessage = null;
                }),
                child: Text(
                  _useRecoveryCode
                      ? 'Use an authenticator code instead'
                      : 'Use a recovery code instead',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
