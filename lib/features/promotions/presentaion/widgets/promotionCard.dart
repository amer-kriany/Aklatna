import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PromotionCard extends StatelessWidget {
  const PromotionCard({
    super.key,
    required this.businessName,
    required this.coverUrl,
    required this.itemName,
    required this.discountPercentage,
    this.oldPrice,
    this.newPrice,
    required this.onTap,
    this.width,
    this.currencySymbol = 'ل.س',
  });

  final String businessName;
  final String? coverUrl;
  final String itemName;
  final int discountPercentage;
  final double? oldPrice;
  final double? newPrice;
  final VoidCallback onTap;
  final double? width;
  final String currencySymbol;

  static const double _coverAspectRatio = 1.35;
  static const double _cardRadius = AppRadius.xl;
  static const double _defaultImageWidth =
      180; // baseline when no explicit width given

  @override
  Widget build(BuildContext context) {
    final double savingsAmount =
        (oldPrice != null && newPrice != null && oldPrice! > newPrice!)
        ? (oldPrice! - newPrice!) + 1
        : 0;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_cardRadius),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: width ?? _defaultImageWidth,
                    child: AspectRatio(
                      aspectRatio: _coverAspectRatio,
                      child: _buildCoverImage(),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'خصم $discountPercentage%',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.storefront_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            businessName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.regularSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Divider(
                  height: 1,
                  thickness: 0.6,
                  color: AppColors.divider,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (oldPrice != null)
                          Text(
                            '${_formatPrice(oldPrice!)} $currencySymbol',
                            style: AppTextStyles.bodySmall.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textHint,
                            ),
                          ),
                        const SizedBox(height: 2),
                        if (newPrice != null)
                          Text(
                            '${_formatPrice(newPrice!)} $currencySymbol',
                            style: AppTextStyles.priceMedium.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    if (savingsAmount > 0) ...[
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'وفر',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_formatPrice(savingsAmount)} $currencySymbol',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  Widget _buildCoverImage() {
    final bool hasValidUrl = coverUrl != null && coverUrl!.isNotEmpty;
    if (!hasValidUrl) return const _ImagePlaceholder();
    return Image.network(
      coverUrl!,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_rounded,
        color: AppColors.primary,
        size: AppSizes.iconXl * 1.4,
      ),
    );
  }
}
