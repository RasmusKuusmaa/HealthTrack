import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../ui/widgets/app_empty_state.dart';
import '../../ui/widgets/unit_aware_number_field.dart';
import '../profile/profile_providers.dart';
import 'weight_providers.dart';
import 'weight_repository.dart';
import 'weight_unit_conversion.dart';

/// Lists the signed-in user's weight entries, newest first, with edit and
/// delete — both applied as ops through [WeightRepository].
class WeightHistoryScreen extends ConsumerWidget {
  const WeightHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repositoryAsync = ref.watch(weightRepositoryProvider);
    final unitSystem = ref
        .watch(currentUnitSystemProvider)
        .maybeWhen(data: (unitSystem) => unitSystem, orElse: () => null);
    final unitLabel = unitLabelFor(unitSystem);

    return Scaffold(
      appBar: AppBar(title: const Text('Weight history')),
      body: repositoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            AppEmptyState(message: 'Could not load your weight history.'),
        data: (repository) => StreamBuilder<List<WeightEntry>>(
          stream: repository.watchAll(),
          builder: (context, snapshot) {
            final entries = snapshot.data ?? const <WeightEntry>[];
            if (entries.isEmpty) {
              return const AppEmptyState(
                message: 'No weight entries yet. Log your first one.',
                icon: Icons.monitor_weight_outlined,
              );
            }

            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Dismissible(
                  key: ValueKey(entry.id),
                  background: Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete_outline),
                  ),
                  onDismissed: (_) => repository.delete(entry.id),
                  child: ListTile(
                    title: Text(_formatDate(entry.localDate)),
                    subtitle: entry.note != null ? Text(entry.note!) : null,
                    trailing: Text(
                      _formatWeight(entry.weightKg, unitSystem, unitLabel),
                    ),
                    onTap: () => _editEntry(
                      context,
                      repository,
                      entry,
                      unitSystem: unitSystem,
                      unitLabel: unitLabel,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _editEntry(
    BuildContext context,
    WeightRepository repository,
    WeightEntry entry, {
    required String? unitSystem,
    required String unitLabel,
  }) async {
    final weightKg = entry.weightKg;
    final displayValue = weightKg == null
        ? null
        : (isImperial(unitSystem) ? kgToLb(weightKg) : weightKg);
    final controller = TextEditingController(
      text: displayValue == null ? '' : displayValue.toString(),
    );
    final noteController = TextEditingController(text: entry.note ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit weight entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UnitAwareNumberField(
              controller: controller,
              unitLabel: unitLabel,
              labelText: 'Weight',
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    final enteredValue = double.tryParse(controller.text.trim());
    final fields = <String, dynamic>{
      'note': noteController.text.trim(),
      if (enteredValue != null)
        'weight_kg': isImperial(unitSystem)
            ? lbToKg(enteredValue)
            : enteredValue,
    };
    await repository.update(entry.id, fields);
  }

  String _formatWeight(double? weightKg, String? unitSystem, String unitLabel) {
    if (weightKg == null) return '—';
    final displayValue = isImperial(unitSystem) ? kgToLb(weightKg) : weightKg;
    return '${displayValue.toStringAsFixed(1)} $unitLabel';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
