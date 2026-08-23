import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/device_platform.dart';
import '../../core/network/api_providers.dart';
import '../../core/router.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/widgets/app_primary_button.dart';
import 'auth_repository.dart';
import 'post_sign_in_navigation.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
        email: _emailController.text.trim(),
        password: _passwordController.text,
        platform: currentDevicePlatform(),
      );

      if (!mounted) return;

      switch (outcome) {
        case LoginOutcome.authenticated:
          await navigateAfterSignIn(context, ref);
        case LoginOutcome.mfaRequired:
          context.push(
            mfaChallengePath,
            extra: PendingLoginCredentials(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Could not sign in. Check your email and password and try again.';
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signInTitle)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l10n.signInEmailLabel),
                validator: (value) => (value == null || !value.contains('@'))
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.signInPasswordLabel,
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Enter your password'
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
                label: l10n.signInTitle,
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.go(registerPath),
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
