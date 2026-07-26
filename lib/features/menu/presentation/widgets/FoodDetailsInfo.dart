import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class FoodDetailsInfo extends StatelessWidget {
  const FoodDetailsInfo({
    super.key,
    required this.title,
    required this.category,
    required this.description,
  });

  final String title;
  final String category;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h2,
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              CircleAvatar(
                radius: AppSizes.iconMd / 2 + 4,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(
                  Icons.fastfood,
                  size: AppSizes.iconSm,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                category,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            description,
            style: AppTextStyles.regularMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}