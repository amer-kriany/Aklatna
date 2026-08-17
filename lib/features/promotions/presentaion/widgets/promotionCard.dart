import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PromotionCard extends StatelessWidget {
  const PromotionCard({
    super.key,
    required this.businessName,
    required this.coverUrl,
    required this.itemName,
    this.label,
    this.menuItemId,
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
  final String? label;
  final String? menuItemId;

  final int discountPercentage;
  final double? oldPrice;
  final double? newPrice;

  final VoidCallback onTap;

  final double? width;
  final String currencySymbol;

  // ===========================================================================
  // CONSTANTS
  // ===========================================================================

  static const double cardHeight = 245.0;
  static const double imageHeight = 120.0;

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  bool get _hasDiscount => discountPercentage > 0;

  String get _displayName {
    if (menuItemId == null &&
        label != null &&
        label!.trim().isNotEmpty) {
      return label!;
    }

    return itemName;
  }

  double get _savingsAmount {
    if (!_hasDiscount ||
        oldPrice == null ||
        newPrice == null ||
        oldPrice! <= newPrice!) {
      return 0;
    }

    return oldPrice! - newPrice!;
  }

  double _resolveWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (width != null) {
      return width!;
    }

    return (screenWidth * 0.44).clamp(
      165.0,
      200.0,
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final cardWidth = _resolveWidth(context);

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            AppRadius.lg,
          ),
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(
                AppRadius.lg,
              ),
              border: Border.all(
                color: AppColors.border.withOpacity(0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // =============================================================
                // IMAGE
                // =============================================================

                SizedBox(
                  width: double.infinity,
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildCoverImage(),

                      if (_hasDiscount)
                        Positioned(
                          top: 9,
                          right: 9,
                          child: _DiscountBadge(
                            discount: discountPercentage,
                          ),
                        ),
                    ],
                  ),
                ),

                // =============================================================
                // CONTENT
                // =============================================================

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm,
                      8,
                      AppSpacing.sm,
                      6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =====================================================
                        // ITEM NAME
                        // =====================================================

                        SizedBox(
                          height: 20,
                          child: Text(
                            _displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 3),

                        // =====================================================
                        // BUSINESS
                        // =====================================================

                        SizedBox(
                          height: 18,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.storefront_rounded,
                                size: 13,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  businessName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.rtl,
                                  style:
                                      AppTextStyles.regularSmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 2),

                        // =====================================================
                        // DIVIDER
                        // =====================================================

                        const Divider(
                          height: 6,
                          thickness: 0.5,
                          color: AppColors.divider,
                        ),

                        // =====================================================
                        // PRICE
                        // =====================================================

                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _PriceBlock(),
                              ),

                              if (_savingsAmount > 0)
                                _SavingsBadge(
                                  amount: _savingsAmount,
                                  currencySymbol: currencySymbol,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // IMAGE
  // ===========================================================================

  Widget _buildCoverImage() {
    if (coverUrl == null || coverUrl!.trim().isEmpty) {
      return const _ImagePlaceholder();
    }

    return Image.network(
      coverUrl!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return const _ImagePlaceholder();
      },
      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return const _ImagePlaceholder();
      },
    );
  }

  // ===========================================================================
  // PRICE
  // ===========================================================================

  Widget _PriceBlock() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_hasDiscount && oldPrice != null)
          Text(
            '${_formatPrice(oldPrice!)} $currencySymbol',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
              fontSize: 9,
              decoration: TextDecoration.lineThrough,
              decorationThickness: 1.2,
            ),
          ),

        if (newPrice != null)
          Text(
            '${_formatPrice(newPrice!)} $currencySymbol',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.priceMedium.copyWith(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // FORMAT
  // ===========================================================================

  String _formatPrice(double price) {
    return price
        .toInt()
        .toString()
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }
}

// =============================================================================
// DISCOUNT BADGE
// =============================================================================

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({
    required this.discount,
  });

  final int discount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(
          AppRadius.full,
        ),
      ),
      child: Text(
        'خصم %$discount',
        maxLines: 1,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 9,
        ),
      ),
    );
  }
}

// =============================================================================
// SAVINGS BADGE
// =============================================================================

class _SavingsBadge extends StatelessWidget {
  const _SavingsBadge({
    required this.amount,
    required this.currencySymbol,
  });

  final double amount;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 62,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(
          AppRadius.sm,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'وفر',
            maxLines: 1,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            '${amount.toInt()} $currencySymbol',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PLACEHOLDER
// =============================================================================

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
        size: AppSizes.iconXl,
      ),
    );
  }
}