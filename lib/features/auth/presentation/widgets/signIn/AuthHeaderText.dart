import 'package:flutter/material.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_style.dart';
import '../../../../../core/theme/app_colors.dart';

class AuthHeaderText extends StatelessWidget {
  const AuthHeaderText({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: AppTextStyles.regularMedium.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}