import 'package:flutter/material.dart';

/// Global loading pattern:
/// show skeleton while loading, then cross-fade to real content.
class SkeletonSwitch extends StatelessWidget {
  const SkeletonSwitch({
    super.key,
    required this.isLoading,
    required this.skeleton,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
  });

  final bool isLoading;
  final Widget skeleton;
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: isLoading
          ? KeyedSubtree(key: const ValueKey('skeleton'), child: skeleton)
          : KeyedSubtree(key: const ValueKey('content'), child: child),
    );
  }
}
