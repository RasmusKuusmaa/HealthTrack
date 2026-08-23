import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_providers.dart';
import '../../core/router.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/widgets/app_primary_button.dart';
import '../profile/profile_providers.dart';
import 'onboarding_intent_store.dart';

const _sexAtBirthOptions = <String, String>{
  'female': 'Female',
  'male': 'Male',
  'intersex': 'Intersex',
  'prefer_not_to_say': 'Prefer not to say',
};

const _goalsIntentLabels = <GoalsIntent, String>{
  GoalsIntent.loseWeight: 'Lose weight',
  GoalsIntent.buildMuscle: 'Build muscle',
  GoalsIntent.maintainAndTrack: 'Maintain and track',
  GoalsIntent.justExploring: 'Just exploring',
};

enum _Step { profile, units, timezone, goals }

/// Collects the basics needed to personalize the app: profile (birth date,
/// sex at birth, height), preferred units, timezone, and a local-only
/// "what are you here for" intent. Reached once, right after the user's
/// first successful sign-in, until their profile is complete.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Step _step = _Step.profile;

  DateTime? _birthDate;
  String? _sexAtBirth;
  final _heightController = TextEditingController();

  String _unitSystem = 'metric';

  final _timezoneController = TextEditingController(text: 'UTC');

  GoalsIntent? _goalsIntent;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _heightController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    switch (_step) {
      case _Step.profile:
        return _birthDate != null &&
            _sexAtBirth != null &&
            double.tryParse(_heightController.text.trim()) != null;
      case _Step.units:
        return true;
      case _Step.timezone:
        return _timezoneController.text.trim().isNotEmpty;
      case _Step.goals:
        return _goalsIntent != null;
    }
  }

  void _continue() {
    switch (_step) {
      case _Step.profile:
        setState(() => _step = _Step.units);
      case _Step.units:
        setState(() => _step = _Step.timezone);
      case _Step.timezone:
        setState(() => _step = _Step.goals);
      case _Step.goals:
        _finish();
    }
  }

  Future<void> _finish() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final profileRepository = await ref.read(
        userProfileRepositoryProvider.future,
      );
      await profileRepository.update({
        'birth_date': _formatDate(_birthDate!),
        'sex_at_birth': _sexAtBirth,
        'height_cm': double.parse(_heightController.text.trim()),
        'unit_system': _unitSystem,
        'timezone': _timezoneController.text.trim(),
      });

      final intentStore = OnboardingIntentStore(
        ref.read(secureKeyValueStoreProvider),
      );
      await intentStore.write(_goalsIntent!);

      if (!mounted) return;
      context.go(homePath);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Could not save your profile. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your profile')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: switch (_step) {
                _Step.profile => _buildProfileStep(context),
                _Step.units => _buildUnitsStep(context),
                _Step.timezone => _buildTimezoneStep(context),
                _Step.goals => _buildGoalsStep(context),
              },
            ),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppPrimaryButton(
              label: _step == _Step.goals ? 'Finish' : 'Continue',
              isLoading: _isSubmitting,
              onPressed: _canContinue ? _continue : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStep(BuildContext context) {
    return ListView(
      children: [
        const Text('When were you born?'),
        const SizedBox(height: AppSpacing.sm),
        AppPrimaryButton(
          label: _birthDate == null
              ? 'Choose birth date'
              : _formatDate(_birthDate!),
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(now.year - 25),
              firstDate: DateTime(now.year - 120),
              lastDate: now,
            );
            if (picked != null) setState(() => _birthDate = picked);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('Sex at birth'),
        for (final entry in _sexAtBirthOptions.entries)
          RadioListTile<String>(
            title: Text(entry.value),
            value: entry.key,
            // ignore: deprecated_member_use
            groupValue: _sexAtBirth,
            // ignore: deprecated_member_use
            onChanged: (value) => setState(() => _sexAtBirth = value),
          ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _heightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Height (cm)'),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildUnitsStep(BuildContext context) {
    return ListView(
      children: [
        const Text('Which units do you prefer?'),
        RadioListTile<String>(
          title: const Text('Metric (kg, cm)'),
          value: 'metric',
          // ignore: deprecated_member_use
          groupValue: _unitSystem,
          // ignore: deprecated_member_use
          onChanged: (value) => setState(() => _unitSystem = value!),
        ),
        RadioListTile<String>(
          title: const Text('Imperial (lb, ft/in)'),
          value: 'imperial',
          // ignore: deprecated_member_use
          groupValue: _unitSystem,
          // ignore: deprecated_member_use
          onChanged: (value) => setState(() => _unitSystem = value!),
        ),
      ],
    );
  }

  Widget _buildTimezoneStep(BuildContext context) {
    return ListView(
      children: [
        const Text(
          'Confirm your timezone (used to know which day an entry belongs to).',
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _timezoneController,
          decoration: const InputDecoration(
            labelText: 'Timezone',
            hintText: 'e.g. Europe/Tallinn',
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildGoalsStep(BuildContext context) {
    return ListView(
      children: [
        const Text("What brings you here?"),
        for (final entry in _goalsIntentLabels.entries)
          RadioListTile<GoalsIntent>(
            title: Text(entry.value),
            value: entry.key,
            // ignore: deprecated_member_use
            groupValue: _goalsIntent,
            // ignore: deprecated_member_use
            onChanged: (value) => setState(() => _goalsIntent = value),
          ),
      ],
    );
  }
}
