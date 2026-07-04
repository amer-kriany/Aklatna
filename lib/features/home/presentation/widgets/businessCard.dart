import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';


/// Reusable business card — used in Trending and Open Now sections.
///
/// Deliberately takes plain typed params instead of a Business entity
/// directly, so this widget doesn't care about the real model shape.
/// Whoever wires the Bloc just maps BusinessEntity -> these params.
///
/// NOTE: no distance/ETA/rating badges — dropped, see chat explanation
/// (not in your schema / Phase 1 scope / ratings deferred to Phase 2).
class BusinessCard extends StatelessWidget {
  const BusinessCard({
    super.key,
    required this.name,
    required this.typeLabel, // e.g. "مطعم" or "محل عصائر"
    required this.imageUrl,
    required this.isOpen,
    this.description,
    this.onTap,
    this.width = 140,
  });

  final String name;
  final String typeLabel;
  final String imageUrl;
  final bool isOpen;
  final String? description;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                  child: Image.network(
                    imageUrl,
                    height: 90,
                    width: width,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 90,
                      width: width,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.storefront_outlined, color: AppColors.textHint),
                    ),
                  ),
                ),
                Positioned(
                  top: AppSpacing.xxs,
                  right: AppSpacing.xxs, // RTL-friendly: badge sits at the leading edge visually
                  child: _OpenBadge(isOpen: isOpen),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    typeLabel,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  const _OpenBadge({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
      ),
      child: Text(
        isOpen ? 'مفتوح' : 'مغلق',
        style: AppTextStyles.overline.copyWith(
          color: isOpen ? AppColors.openBadge : AppColors.closedBadge,
        ),
      ),
    );
  }
}