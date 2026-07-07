import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class BusinessCard extends StatelessWidget {
  final String businessName;
  final String? coverUrl;
  final double? rating;
  final int? ratingCount;
  final VoidCallback onTap;

  /// Fixed width for horizontal-list tiles (e.g. "Recommended" row).
  /// Leave null to let the card fill whatever width the parent gives it
  /// (grid layouts, full-width lists, etc).
  final double? width;

  /// Controls image shape. Defaults to 16:9. Pass a squarer or taller
  /// ratio (e.g. 1 or 4/3) for different card variants without touching
  /// this widget's internals.
  final double imageAspectRatio;

  const BusinessCard({
    super.key,
    required this.businessName,
    required this.onTap,
    this.coverUrl,
    this.rating,
    this.ratingCount,
    this.width,
    this.imageAspectRatio = 16 / 9,
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
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: imageAspectRatio,
                child: _buildImage(),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (rating != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      _buildRating(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (coverUrl == null || coverUrl!.isEmpty) {
      return Container(
        color: AppColors.surfaceVariant,
        child: Icon(
          Icons.storefront_outlined,
          color: AppColors.textSecondary,
          size: AppSizes.iconXl,
        ),
      );
    }

    return Image.network(
      coverUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.surfaceVariant,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.surfaceVariant,
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondary,
            size: AppSizes.iconXl,
          ),
        );
      },
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            final filled = index < rating!.round();
            return Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              size: AppSizes.iconSm,
              color: AppColors.primary,
            );
          }),
        ),
        if (ratingCount != null) ...[
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '($ratingCount)',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}