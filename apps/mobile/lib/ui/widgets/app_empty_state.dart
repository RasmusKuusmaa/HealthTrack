import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Shown in place of a list or screen with nothing in it yet, with an
/// optional call-to-action (e.g. "Log your first entry").
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    super.key,
  });

  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            if (action != null) ...[const SizedBox(height: AppSpacing.md), action!],
          ],
        ),
      ),
    );
  }
}
