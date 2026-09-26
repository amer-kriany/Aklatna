
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

  static const double cardHeight = 250;
  static const double imageHeight = 142;

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

    return (screenWidth * 0.47).clamp(175.0, 205.0);
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = _resolveWidth(context);

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primary.withOpacity(0.06),
          highlightColor: AppColors.primary.withOpacity(0.03),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: AppColors.border.withOpacity(0.45),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(cardWidth),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      10,
                      12,
                      10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------------------------------------------------
                        // BUSINESS
                        // ---------------------------------------------------

                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                businessName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.rtl,
                                style: AppTextStyles.regularSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // ---------------------------------------------------
                        // ITEM NAME
                        // ---------------------------------------------------

                        Text(
                          _displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),

                        const Spacer(),

                        // ---------------------------------------------------
                        // PRICE + CTA
                        // ---------------------------------------------------

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: _buildPrice(),
                            ),

                            const SizedBox(width: 8),

                            _buildArrowButton(),
                          ],
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

  Widget _buildImage(double cardWidth) {
    return SizedBox(
      width: double.infinity,
      height: imageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildCoverImage(),

          // Soft bottom gradient so the image blends naturally
          // into the card instead of looking like a separate rectangle.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.55, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.18),
                  ],
                ),
              ),
            ),
          ),

          // ---------------------------------------------------------------
          // DISCOUNT
          // ---------------------------------------------------------------

          if (_hasDiscount)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(
                    AppRadius.full,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.16),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'خصم %$discountPercentage',
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

          // ---------------------------------------------------------------
          // DEAL LABEL
          // ---------------------------------------------------------------

          if (label != null &&
              label!.trim().isNotEmpty &&
              menuItemId != null)
            Positioned(
              bottom: 9,
              left: 10,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: cardWidth * 0.62,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.52),
                  borderRadius: BorderRadius.circular(
                    AppRadius.full,
                  ),
                ),
                child: Text(
                  label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    if (coverUrl == null || coverUrl!.trim().isEmpty) {
      return const _ImagePlaceholder();
    }

    return Image.network(
      coverUrl!,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) {
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

  Widget _buildPrice() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (oldPrice != null && _hasDiscount)
          Row(
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_formatPrice(oldPrice!)} $currencySymbol',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                  fontSize: 9.5,
                  decoration: TextDecoration.lineThrough,
                  decorationThickness: 1.2,
                ),
              ),

              if (_savingsAmount > 0) ...[
                const SizedBox(width: 5),
                Text(
                  'وفر ${_formatPrice(_savingsAmount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),

        const SizedBox(height: 1),

        if (newPrice != null)
          Text(
            '${_formatPrice(newPrice!)} $currencySymbol',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.priceMedium.copyWith(
              color: AppColors.primary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // CTA
  // ===========================================================================

  Widget _buildArrowButton() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.20),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.arrow_back_rounded,
        color: AppColors.textOnPrimary,
        size: 19,
      ),
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

