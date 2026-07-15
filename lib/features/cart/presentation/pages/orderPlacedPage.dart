import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

/// Shown briefly after a successful checkout — no buttons, auto-dismisses
/// back to Home after 3 seconds.
class OrderPlacedPage extends StatefulWidget {
  const OrderPlacedPage({super.key});

  @override
  State<OrderPlacedPage> createState() => _OrderPlacedPageState();
}

class _OrderPlacedPageState extends State<OrderPlacedPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 96,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'تم إرسال طلبك بنجاح!',
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
  'رح نعلمك أول ما المطعم يبلش يحضر طلبك',
  style: AppTextStyles.regularMedium.copyWith(color: AppColors.textSecondary),
  textAlign: TextAlign.center,
),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}