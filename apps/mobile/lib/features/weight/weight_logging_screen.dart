import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/theme/app_spacing.dart';
import '../../ui/widgets/app_primary_button.dart';
import '../../ui/widgets/unit_aware_number_field.dart';
import '../profile/profile_providers.dart';
import 'weight_entry_payload.dart';
import 'weight_providers.dart';
import 'weight_unit_conversion.dart';

/// Logs a single weight entry for right now, in the signed-in user's
/// preferred unit — always converted to and stored canonically in kg.
class WeightLoggingScreen extends ConsumerStatefulWidget {
  const WeightLoggingScreen({super.key});

  @override
  ConsumerState<WeightLoggingScreen> createState() =>
      _WeightLoggingScreenState();
}

class _WeightLoggingScreenState extends ConsumerState<WeightLoggingScreen> {
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double? get _enteredValue => double.tryParse(_weightController.text.trim());

  bool get _canSave => _enteredValue != null && _enteredValue! > 0;

  bool get _isImperial => isImperial(
    ref
        .read(currentUnitSystemProvider)
        .maybeWhen(data: (unitSystem) => unitSystem, orElse: () => null),
  );

  Future<void> _save() async {
    final enteredValue = _enteredValue;
    if (enteredValue == null) return;
    final weightKg = _isImperial ? lbToKg(enteredValue) : enteredValue;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final repository = await ref.read(weightRepositoryProvider.future);
      await repository.create(
        buildWeightEntryPayload(
          weightKg: weightKg,
          note: _noteController.text.trim(),
        ),
      );

      if (!mounted) return;
      _weightController.clear();
      _noteController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Weight logged')));
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Could not save your weight. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitSystem = ref
        .watch(currentUnitSystemProvider)
        .maybeWhen(data: (unitSystem) => unitSystem, orElse: () => null);
    final unitLabel = unitLabelFor(unitSystem);

    return Scaffold(
      appBar: AppBar(title: const Text('Log weight')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UnitAwareNumberField(
              controller: _weightController,
              unitLabel: unitLabel,
              labelText: 'Weight',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppPrimaryButton(
              label: 'Save',
              isLoading: _isSubmitting,
              onPressed: _canSave ? _save : null,
            ),
          ],
        ),
      ),
    );
  }
}
