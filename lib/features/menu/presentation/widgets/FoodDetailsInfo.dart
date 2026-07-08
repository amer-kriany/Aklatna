import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class FoodDetailsInfo extends StatelessWidget {
  const FoodDetailsInfo({
    super.key,
    required this.title,
    required this.category,
    required this.rating,
    required this.deliveryFee,
    required this.deliveryTime,
    required this.description,
  });

  final String title;
  final String category;
  final double rating;
  final String deliveryFee;
  final String deliveryTime;
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
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.amber,
                child: Icon(
                  Icons.fastfood,
                  size: 16,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Text(
                category,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(width: AppSpacing.lg),

              const Icon(
                Icons.delivery_dining,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                deliveryFee,
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(width: AppSpacing.lg),

              const Icon(
                Icons.access_time,
                color: Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                deliveryTime,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey.shade600,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}