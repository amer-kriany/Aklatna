import 'package:flutter/material.dart';

import '../../../../../core/constants/app_text_style.dart';
import '../../../../../core/theme/app_colors.dart';

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  final String text;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: text, style: AppTextStyles.regularMedium.copyWith(color: AppColors.textSecondary)),
              TextSpan(text: ' $actionText', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}