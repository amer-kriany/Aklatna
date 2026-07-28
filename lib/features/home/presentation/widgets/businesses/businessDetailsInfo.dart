import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';



class BusinessDetailsInfo extends StatelessWidget {
  const BusinessDetailsInfo({
    super.key,
    required this.nameAr,
    required this.rating,
    required this.description,
  });

  final String nameAr;
  final double rating;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.warning, size: AppSizes.iconSm),
              const SizedBox(width: AppSpacing.xxs),
              

              const SizedBox(width: AppSpacing.lg),

              // NOTE: dummy placeholder — no delivery fee column/logic in
              // Phase 1 schema. Replace or remove once real logic exists.
              const Icon(Icons.delivery_dining, color: AppColors.primary, size: AppSizes.iconSm),
              const SizedBox(width: AppSpacing.xxs),
              Text('Free', style: AppTextStyles.bodyMedium),

              const SizedBox(width: AppSpacing.lg),

              // NOTE: dummy placeholder — same as above.
              const Icon(Icons.access_time, color: AppColors.warning, size: AppSizes.iconSm),
              const SizedBox(width: AppSpacing.xxs),
              Text('20 min', style: AppTextStyles.bodyMedium),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            nameAr,
            style: AppTextStyles.h2,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            description,
            style: AppTextStyles.regularMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}