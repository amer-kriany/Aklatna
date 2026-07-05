import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A single sponsored/advertising banner (paid placement).
/// Pure presentation - doesn't know or care where the image URL comes from,
/// or how "active subscription" is determined. That logic lives entirely
/// in the data/domain layer once the backing table exists.
class SponsoredBanner extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  /// Defaults to a wide banner shape matching typical ad creative.
  /// Override if a specific banner batch uses a different ratio.
  final double aspectRatio;

  const SponsoredBanner({
    super.key,
    required this.imageUrl,
    required this.onTap,
    this.aspectRatio = 2.2,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: AppColors.surfaceVariant,
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
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
          ),
        ),
      ),
    );
  }
}