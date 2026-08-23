import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A titled section divider, with an optional trailing action (e.g. "See
/// all").
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
