import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileMenuRow extends StatelessWidget {
  const ProfileMenuRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.textColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;

  static const double _iconCircleSize = 40;

  @override
  Widget build(BuildContext context) {
    // If it's an error icon (Log Out), automatically make text red unless specified
    final bool isDestructive = iconColor == AppColors.error;
    final Color effectiveTextColor = textColor ??
        (isDestructive ? AppColors.error : AppColors.textPrimary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: _iconCircleSize,
              height: _iconCircleSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDestructive
                      ? AppColors.error.withOpacity(0.2)
                      : AppColors.border,
                ),
                color: isDestructive
                    ? AppColors.error.withOpacity(0.05)
                    : AppColors.background,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: AppSizes.iconMd),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: effectiveTextColor,
                  fontWeight:
                      isDestructive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_left,
              color: AppColors.textHint,
              size: AppSizes.iconMd,
            ),
          ],
        ),
      ),
    );
  }
}