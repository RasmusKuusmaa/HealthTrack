import 'package:flutter/material.dart';

/// A pulsing placeholder rectangle standing in for content that's still
/// loading (a list row, a chart, a card body).
class AppLoadingSkeleton extends StatefulWidget {
  const AppLoadingSkeleton({this.width, this.height = 16, this.borderRadius = 8, super.key});

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<AppLoadingSkeleton> createState() => _AppLoadingSkeletonState();
}

class _AppLoadingSkeletonState extends State<AppLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(opacity: 0.4 + (_controller.value * 0.3), child: child);
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
