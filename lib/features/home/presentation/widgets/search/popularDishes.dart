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
    required this.dishPrice, required this.onTap,
  });

  final String photoUrl;
  final String dishNameAr;
  final String businessNameAr;
  final double dishPrice;
  final GestureTapCallback onTap;

  bool get _hasValidImageUrl {
    final uri = Uri.tryParse(photoUrl.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              child: _hasValidImageUrl
                  ? Image.network(
                      photoUrl,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 100,
                      width: double.infinity,
                      color: AppColors.surface,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.fastfood,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dishPrice.toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Column(
                  spacing: 4,
                  children: [
                    Text(
                      dishNameAr,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
      
                    Text(
                      businessNameAr,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
