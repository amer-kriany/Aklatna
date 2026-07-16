import 'package:flutter/material.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_style.dart';
import '../../../../../core/theme/app_colors.dart';

/// Google sign-in — stub only, no usecase wired yet.
class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.g_mobiledata_rounded, size: AppSizes.iconLg, color: AppColors.textPrimary),
            const SizedBox(width: AppSpacing.xs),
            Text('المتابعة عبر جوجل', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}