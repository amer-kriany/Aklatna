import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onMicTap;

  const HomeSearchBar({
    super.key,
    required this.onTap,
    this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: AppSizes.inputHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: AppSizes.iconMd,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'دور على أكلة أو مطعم...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onMicTap,
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  Icons.mic_none_rounded,
                  color: AppColors.textSecondary,
                  size: AppSizes.iconMd,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}