import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Reusable skeleton primitive for loading placeholders.
class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.radius = 12,
    this.isCircle = false,
    this.margin,
    this.baseColor,
    this.highlightColor,
    this.animate = true,
  });

  final double? width;
  final double? height;
  final double radius;
  final bool isCircle;
  final EdgeInsetsGeometry? margin;
  final Color? baseColor;
  final Color? highlightColor;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final resolvedBaseColor = baseColor ?? AppColors.shimmerBase;
    final resolvedHighlightColor = highlightColor ?? AppColors.shimmerHighlight;

    final child = Container(
      width: isCircle ? (width ?? height ?? 44) : width,
      height: isCircle ? (height ?? width ?? 44) : height,
      margin: margin,
      decoration: BoxDecoration(
        color: resolvedBaseColor,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
      ),
    );

    if (!animate) return child;

    return Shimmer.fromColors(
      baseColor: resolvedBaseColor,
      highlightColor: resolvedHighlightColor,
      child: child,
    );
  }
}
