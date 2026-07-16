import 'package:flutter/material.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_style.dart';
import '../../../../../core/theme/app_colors.dart';

/// Simple wordmark placeholder — swap for real logo asset when ready.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSizes.avatarSm,
          height: AppSizes.avatarSm,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.restaurant, color: AppColors.textOnPrimary, size: AppSizes.iconMd),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('أكلتنا', style: AppTextStyles.h3),
      ],
    );
  }
}