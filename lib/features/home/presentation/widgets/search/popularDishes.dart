import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Bloc-blind — takes plain values, no entity/Bloc knowledge.
/// No onTap param — page layer wraps with GestureDetector.
class PopularDishCard extends StatelessWidget {
  const PopularDishCard({
    super.key,
    required this.photoUrl,
    required this.dishNameAr,
    required this.businessNameAr,
  });

  final String photoUrl;
  final String dishNameAr;
  final String businessNameAr;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.network(
              photoUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(dishNameAr, style: AppTextStyles.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            businessNameAr,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}