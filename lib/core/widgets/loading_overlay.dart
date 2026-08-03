import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'skeleton.dart';

/// Reusable full-screen loading overlay.
/// Wrap any screen body with this and toggle `isLoading` from the
/// Bloc's state (e.g. state is SomethingLoading) to show a blocking spinner.
///
/// Example:
///   LoadingOverlay(
///     isLoading: state is OrdersLoading,
///     child: OrdersListView(...),
///   )
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: AppColors.overlay,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Skeleton(
                      width: 46,
                      height: 46,
                      isCircle: true,
                      baseColor: AppColors.shimmerBase,
                      highlightColor: AppColors.shimmerHighlight,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        message!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
