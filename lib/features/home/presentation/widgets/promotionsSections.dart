import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/home/presentation/widgets/sectionHeader.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';


/// Single promotion banner card — replaces Figma's generic discount
/// images with your real `promotions` table fields (label, discount_percentage).
class PromotionBanner extends StatelessWidget {
  const PromotionBanner({
    super.key,
    required this.businessName,
    required this.label,
    required this.discountPercentage,
    required this.imageUrl,
    this.onTap,
  });

  final String businessName;
  final String label;
  final int discountPercentage;
  final String imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            onError: (_, __) {},
          ),
          color: AppColors.surfaceVariant, // fallback if image fails
        ),
        child: Stack(
          children: [
            // Gradient scrim for text legibility over the image
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.overlay],
                  ),
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs, // leading edge in RTL
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'خصم $discountPercentage%',
                  style: AppTextStyles.overline.copyWith(color: AppColors.textOnPrimary),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    businessName,
                    style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// خصومات section — active promotions per your PRD
/// (public read where is_active=true AND now() BETWEEN starts_at AND ends_at).
/// TODO: connect to HomeBloc. Replace [items] with real active promotions.
class PromotionsSection extends StatelessWidget {
  const PromotionsSection({
    super.key,
    required this.items,
    this.onSeeAll,
    this.onBannerTap,
  });

  final List<PromotionCardData> items;
  final VoidCallback? onSeeAll;
  final ValueChanged<String>? onBannerTap; // callback receives businessId

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'خصومات', onSeeAll: onSeeAll),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = items[index];
              return PromotionBanner(
                businessName: item.businessName,
                label: item.label,
                discountPercentage: item.discountPercentage,
                imageUrl: item.imageUrl,
                onTap: () => onBannerTap?.call(item.businessId),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Plain data holder for one promotion card.
/// TODO: replace with your real Promotion entity when wiring the Bloc.
class PromotionCardData {
  const PromotionCardData({
    required this.businessId,
    required this.businessName,
    required this.label,
    required this.discountPercentage,
    required this.imageUrl,
  });

  final String businessId;
  final String businessName;
  final String label;
  final int discountPercentage;
  final String imageUrl;
}