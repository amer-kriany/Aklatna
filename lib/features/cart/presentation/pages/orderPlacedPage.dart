import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class OrderPlacedPage extends StatefulWidget {
  const OrderPlacedPage({super.key});

  @override
  State<OrderPlacedPage> createState() => _OrderPlacedPageState();
}

class _OrderPlacedPageState extends State<OrderPlacedPage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;

  late final AnimationController _animationController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 650,
      ),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();

    _timer = Timer(
      const Duration(seconds: 3),
      () {
        if (mounted) {
          context.go('/home');
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
        border: Border.all(
          color: AppColors.border.withOpacity(0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(
              0,
              12,
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSuccessIcon(),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Text(
            'تم إرسال طلبك بنجاح',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          Text(
            'طلبك وصل للمطعم بنجاح',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          _buildNextStep(),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          _buildReturnIndicator(),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.10),
        shape: BoxShape.circle,
      ),
      child: Container(
        margin: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_rounded,
          size: 42,
          color: AppColors.success,
        ),
      ),
    );
  }

  Widget _buildNextStep() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),

          const SizedBox(
            width: AppSpacing.sm,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'ماذا بعد؟',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  'رح نعلمك أول ما المطعم يبلش يحضر طلبك',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnIndicator() {
    return Column(
      children: [
        Text(
          'العودة للرئيسية',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        ClipRRect(
          borderRadius: BorderRadius.circular(
            AppRadius.full,
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: 1,
            ),
            duration: const Duration(
              seconds: 3,
            ),
            builder: (
              context,
              value,
              child,
            ) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 3,
                backgroundColor:
                    AppColors.border.withOpacity(0.35),
                valueColor:
                    AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}