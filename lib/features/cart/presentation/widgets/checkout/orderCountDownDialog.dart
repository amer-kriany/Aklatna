import 'dart:async';
import 'dart:ui';

import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OrderCountdownDialog extends StatefulWidget {
  const OrderCountdownDialog({super.key});

  @override
  State<OrderCountdownDialog> createState() => _OrderCountdownDialogState();

  static Future<bool?> show(BuildContext context) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const OrderCountdownDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(opacity: curved, child: child);
      },
    );
  }
}

class _OrderCountdownDialogState extends State<OrderCountdownDialog>
    with TickerProviderStateMixin {
  static const int _totalSeconds = 5;

  int _secondsLeft = _totalSeconds;

  Timer? _timer;

  late final AnimationController _entranceController;
  late final AnimationController _countdownController;
  late final AnimationController _buttonController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1,
      value: 1,
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _entranceController.forward();

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsLeft <= 1) {
        timer.cancel();

        Navigator.of(context).pop(true);
        return;
      }

      setState(() {
        _secondsLeft--;
      });

      _countdownController
        ..reset()
        ..forward();
    });
  }

  Future<void> _cancel() async {
    _timer?.cancel();

    await _buttonController.reverse();

    if (!mounted) return;

    Navigator.of(context).pop(false);
  }

  @override
  void dispose() {
    _timer?.cancel();

    _entranceController.dispose();
    _countdownController.dispose();
    _buttonController.dispose();

    super.dispose();
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
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 7 * value,
                        sigmaY: 7 * value,
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.28 * value),
                      ),
                    );
                  },
                ),
              ),

              Center(
                child: AnimatedBuilder(
                  animation: _entranceController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _opacityAnimation,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 26),
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 32,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTopIcon(),

                        const SizedBox(height: 14),

                        Text(
                          'تأكيد الطلب',
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'سيتم إرسال طلبك خلال لحظات',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 22),

                        _buildCountdown(progress),

                        const SizedBox(height: 18),

                        _buildHint(),

                        const SizedBox(height: 20),

                        _buildCancelButton(),
                      ],
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

  Widget _buildTopIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check_rounded, color: AppColors.primary, size: 23),
    );
  }

  Widget _buildCountdown(double progress) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return SizedBox(
                width: 92,
                height: 92,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.border.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            },
          ),

          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0, 0.25),
                    end: Offset.zero,
                  ).animate(animation);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: Text(
                  '$_secondsLeft',
                  key: ValueKey(_secondsLeft),
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline_rounded, size: 15, color: AppColors.textHint),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'يمكنك إلغاء الطلب قبل انتهاء الوقت',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTapDown: (_) {
        _buttonController.reverse();
      },
      onTapUp: (_) {
        _buttonController.forward();
      },
      onTapCancel: () {
        _buttonController.forward();
      },
      onTap: _cancel,
      child: ScaleTransition(
        scale: _buttonController,
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withOpacity(0.7)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.close_rounded, size: 18, color: AppColors.error),
              const SizedBox(width: 7),
              Text(
                'إلغاء الطلب',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
