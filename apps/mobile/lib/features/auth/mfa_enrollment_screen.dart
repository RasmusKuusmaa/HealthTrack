import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthtrack_api_client/healthtrack_api_client.dart';

import '../../core/network/api_providers.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/widgets/app_error_state.dart';
import '../../ui/widgets/app_primary_button.dart';

enum _EnrollmentStep {
  loadingQrCode,
  enteringCode,
  showingRecoveryCodes,
  loadFailed,
}

/// Turns on TOTP MFA for the current (authenticated) user: show a QR code,
/// confirm with a code from the authenticator app, then show the one-time
/// recovery codes.
class MfaEnrollmentScreen extends ConsumerStatefulWidget {
  const MfaEnrollmentScreen({super.key});

  @override
  ConsumerState<MfaEnrollmentScreen> createState() =>
      _MfaEnrollmentScreenState();
}

class _MfaEnrollmentScreenState extends ConsumerState<MfaEnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  _EnrollmentStep _step = _EnrollmentStep.loadingQrCode;
  TotpEnrollResponse? _enrollment;
  List<String>? _recoveryCodes;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startEnrollment();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _startEnrollment() async {
    setState(() => _step = _EnrollmentStep.loadingQrCode);
    try {
      final repository = await ref.read(authRepositoryProvider.future);
      final enrollment = await repository.enrollTotp();
      if (!mounted) return;
      setState(() {
        _enrollment = enrollment;
        _step = _EnrollmentStep.enteringCode;
      });
    } catch (_) {
      if (mounted) setState(() => _step = _EnrollmentStep.loadFailed);
    }
  }

  Future<void> _confirm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final repository = await ref.read(authRepositoryProvider.future);
      final codes = await repository.confirmTotp(_codeController.text.trim());
      if (!mounted) return;
      setState(() {
        _recoveryCodes = codes;
        _step = _EnrollmentStep.showingRecoveryCodes;
      });
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
      appBar: AppBar(title: const Text('Set up two-factor authentication')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: switch (_step) {
          _EnrollmentStep.loadingQrCode => const Center(
            child: CircularProgressIndicator(),
          ),
          _EnrollmentStep.loadFailed => AppErrorState(
            message: 'Could not start enrollment. Please try again.',
            onRetry: _startEnrollment,
          ),
          _EnrollmentStep.enteringCode => _buildCodeEntry(context),
          _EnrollmentStep.showingRecoveryCodes => _buildRecoveryCodes(context),
        },
      ),
    );
  }

  Widget _buildCodeEntry(BuildContext context) {
    final enrollment = _enrollment!;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Scan this QR code with your authenticator app.'),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Image.memory(
              base64Decode(enrollment.qrCodePngBase64),
              width: 200,
              height: 200,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SelectableText(
            enrollment.provisioningUri,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Authentication code'),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Enter a code' : null,
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
            label: 'Confirm',
            isLoading: _isSubmitting,
            onPressed: _confirm,
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryCodes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Save these recovery codes somewhere safe. Each one can be used '
          "once to sign in if you lose access to your authenticator app. "
          "They won't be shown again.",
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final code in _recoveryCodes!)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: SelectableText(
              code,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        AppPrimaryButton(
          label: "I've saved these codes",
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}
