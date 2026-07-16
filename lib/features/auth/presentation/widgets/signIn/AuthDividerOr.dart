import 'package:flutter/material.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_style.dart';
import '../../../../../core/theme/app_colors.dart';

class AuthDividerOr extends StatelessWidget {
  const AuthDividerOr({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text('أو', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}