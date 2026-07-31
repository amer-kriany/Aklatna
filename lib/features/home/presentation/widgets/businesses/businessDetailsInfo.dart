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
    required this.isOpen,
    required this.deliveryFeeText,
  });

  final String nameAr;
  final double rating;
  final String description;
  final bool isOpen;
  final String deliveryFeeText;

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
              Text(rating.toStringAsFixed(1), style: AppTextStyles.bodyMedium),
              const SizedBox(width: AppSpacing.lg),

              const Icon(Icons.delivery_dining, color: AppColors.primary, size: AppSizes.iconSm),
              const SizedBox(width: AppSpacing.xxs),
              Text(deliveryFeeText, style: AppTextStyles.bodyMedium),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ============================================================
          // BUSINESS NAME + OPEN/CLOSED STATUS
          // ============================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  nameAr,
                  style: AppTextStyles.h2,
                ),
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              // ==========================================================
              // LIVE STATUS
              // ==========================================================

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isOpen
                      ? Colors.green.withOpacity(0.10)
                      : Colors.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isOpen
                            ? Colors.green
                            : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    Text(
                      isOpen
                          ? 'مفتوح الآن'
                          : 'مغلق الآن',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isOpen
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          // ============================================================
          // DESCRIPTION
          // ============================================================

          if (description.trim().isNotEmpty)
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