import 'dart:math' as math;

import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class HomeSearchBar extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback? onMicTap;

  const HomeSearchBar({
    super.key,
    required this.onTap,
    this.onMicTap,
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.lg);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: AppSizes.inputHeight,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _MovingBorderPainter(
              progress: _controller.value,
              radius: AppRadius.lg,
              color: AppColors.primary,
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.2),
              child: Material(
                color: Colors.white,
                borderRadius: radius,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: radius,
                  splashColor: AppColors.primary.withOpacity(0.05),
                  highlightColor: AppColors.primary.withOpacity(0.025),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                          size: AppSizes.iconMd,
                        ),

                        const SizedBox(
                          width: AppSpacing.xs,
                        ),

                        Expanded(
                          child: Text(
                            'دور على أكلة أو مطعم...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: AppSpacing.sm,
                        ),

                        GestureDetector(
                          onTap: widget.onMicTap,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.mic_none_rounded,
                              color: AppColors.textSecondary,
                              size: AppSizes.iconMd,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MovingBorderPainter extends CustomPainter {
  final double progress;
  final double radius;
  final Color color;

  const _MovingBorderPainter({
    required this.progress,
    required this.radius,
    required this.color,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final rect = Offset.zero & size;

    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.7),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);

    final metrics = path.computeMetrics().first;
    final totalLength = metrics.length;

    // ------------------------------------------------------------
    // Position of the moving highlight
    // ------------------------------------------------------------

    final currentPosition =
        (progress * totalLength) % totalLength;

    // ------------------------------------------------------------
    // Very soft ambient border
    // ------------------------------------------------------------

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = color.withOpacity(0.055);

    canvas.drawRRect(
      rrect,
      basePaint,
    );

    // ------------------------------------------------------------
    // Moving light trail
    // ------------------------------------------------------------

    const trailLength = 0.22;

    final startDistance =
        currentPosition - totalLength * trailLength;

    final endDistance = currentPosition;

    Path trailPath;

    if (startDistance < 0) {
      final firstPart = metrics.extractPath(
        0,
        endDistance,
      );

      final secondPart = metrics.extractPath(
        totalLength + startDistance,
        totalLength,
      );

      trailPath = Path()
        ..addPath(secondPart, Offset.zero)
        ..addPath(firstPart, Offset.zero);
    } else {
      trailPath = metrics.extractPath(
        startDistance,
        endDistance,
      );
    }

    // ------------------------------------------------------------
    // Glow underneath the highlight
    // ------------------------------------------------------------

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        5,
      );

    canvas.drawPath(
      trailPath,
      glowPaint,
    );

    // ------------------------------------------------------------
    // Main soft highlight
    // ------------------------------------------------------------

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.10),
          color.withOpacity(0.30),
          color.withOpacity(0.65),
          color.withOpacity(0.90),
        ],
      ).createShader(rect);

    canvas.drawPath(
      trailPath,
      highlightPaint,
    );

    // ------------------------------------------------------------
    // Small soft leading point
    // ------------------------------------------------------------

    final tangent =
        metrics.getTangentForOffset(currentPosition);

    if (tangent != null) {
      final point = tangent.position;

      final pulse =
          0.5 +
          0.5 *
              math.sin(
                progress * math.pi * 2,
              );

      final glowPointPaint = Paint()
        ..color = color.withOpacity(
          0.18 + pulse * 0.08,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          4,
        );

      canvas.drawCircle(
        point,
        2.5,
        glowPointPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _MovingBorderPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress;
  }
}
