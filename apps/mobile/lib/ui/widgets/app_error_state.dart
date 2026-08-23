import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_primary_button.dart';

/// Shown in place of a screen or section that failed to load, with an
/// optional retry action.
class AppErrorState extends StatelessWidget {
  const AppErrorState({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppPrimaryButton(label: 'Retry', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
