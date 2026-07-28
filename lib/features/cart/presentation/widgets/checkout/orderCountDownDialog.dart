import 'dart:async';
import 'dart:ui';

import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';



// ===========================================================================
// ORDER COUNTDOWN DIALOG (modern version)
// ===========================================================================
//
// Same behavior as before: 5s window to cancel before PlaceOrderEvent
// fires. Visual upgrade —
//   - frosted glass full-screen backdrop (BackdropFilter blur)
//   - scale + fade entrance animation
//   - glowing/pulsing countdown ring
//   - filled danger button with icon instead of plain outlined button
//
// IMPORTANT: this widget is full-screen (Positioned.fill + Center), so it
// must be shown via showGeneralDialog with barrierColor: Colors.transparent
// — NOT showDialog/Dialog. See usage at the bottom of this file.
// ===========================================================================

class OrderCountdownDialog extends StatefulWidget {
  const OrderCountdownDialog({super.key});

  @override
  State<OrderCountdownDialog> createState() => _OrderCountdownDialogState();

  // ============================================================
  // SHOW HELPER
  // ============================================================
  //
  // Call this instead of showDialog(). Returns true if the countdown
  // finished naturally (proceed with placing the order), false if the
  // customer tapped cancel.
  // ============================================================

  static Future<bool?> show(BuildContext context) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (context, _, __) => const OrderCountdownDialog(),
    );
  }
}

class _OrderCountdownDialogState extends State<OrderCountdownDialog>
    with TickerProviderStateMixin {
  static const int _totalSeconds = 5;

  int _secondsLeft = _totalSeconds;
  Timer? _timer;

  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();

        if (mounted) {
          Navigator.of(context).pop(true);
        }
        return;
      }

      setState(() {
        _secondsLeft--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _cancel() {
    _timer?.cancel();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _secondsLeft / _totalSeconds;

    return PopScope(
      canPop: false,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Full-screen frosted backdrop
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    color: Colors.black.withOpacity(0.25),
                  ),
                ),
              ),

              // Centered card
              Center(
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _entranceController,
                    curve: Curves.easeOutBack,
                  ),
                  child: FadeTransition(
                    opacity: _entranceController,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: -8,
                            offset: const Offset(0, 20),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ============================
                          // COUNTDOWN RING WITH GLOW
                          // ============================
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final glowStrength =
                                  0.15 + (_pulseController.value * 0.15);

                              return Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withOpacity(glowStrength),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 92,
                                  height: 92,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 6,
                                    strokeCap: StrokeCap.round,
                                    backgroundColor:
                                        AppColors.border.withOpacity(0.4),
                                    valueColor: const AlwaysStoppedAnimation(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    );
                                  },
                                  child: Text(
                                    '$_secondsLeft',
                                    key: ValueKey(_secondsLeft),
                                    style: AppTextStyles.h2.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          Text(
                            'جاري إرسال طلبك',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h4.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'يمكنك التراجع خلال الثواني القادمة فقط',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // ============================
                          // CANCEL BUTTON — filled, modern
                          // ============================
                          SizedBox(
                            width: double.infinity,
                            child: Material(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: _cancel,
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.close_rounded,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'إلغاء الطلب',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}