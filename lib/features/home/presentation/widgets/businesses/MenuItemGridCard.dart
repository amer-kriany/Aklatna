import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MenuItemGridCard extends StatelessWidget {
  const MenuItemGridCard({
    super.key,
    required this.nameAr,
    required this.price,
    this.photoUrl,
    this.businessNameAr,
    this.quantity,
    this.onAdd,
    this.onRemove,
    this.onTap,
    this.oldPrice,
    this.discountPercentage,
  });

  final String nameAr;
  final double price;
  final String? photoUrl;
  final String? businessNameAr;

  final int? quantity;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  final double? oldPrice;
  final int? discountPercentage;

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  bool get _hasDiscount {
    return oldPrice != null &&
        discountPercentage != null &&
        discountPercentage! > 0;
  }

  bool get _hasImage {
    return photoUrl != null && photoUrl!.trim().isNotEmpty;
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border.withOpacity(0.45),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImage(),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  11,
                  9,
                  11,
                  10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ===========================================================
                    // FOOD NAME
                    // ===========================================================

                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        nameAr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          height: 1.25,
                        ),
                      ),
                    ),

                    // ===========================================================
                    // BUSINESS NAME
                    // ===========================================================

                    if (businessNameAr != null &&
                        businessNameAr!.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                businessNameAr!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 9),

                    // ===========================================================
                    // PRICE RIGHT / ARROW LEFT
                    // ===========================================================

                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // -----------------------------------------------------
                          // ARROW — LEFT
                          // -----------------------------------------------------

                          if (onTap != null) _buildDetailsButton(),

                          // -----------------------------------------------------
                          // SPACE BETWEEN ARROW AND PRICE
                          // -----------------------------------------------------

                          if (onTap != null)
                            const SizedBox(width: 7),

                          // -----------------------------------------------------
                          // PRICE — RIGHT
                          // -----------------------------------------------------

                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: _buildPrice(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // IMAGE
  // ===========================================================================

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 1.18,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImageContent(),

          // =====================================================================
          // DISCOUNT BADGE
          // =====================================================================

          if (_hasDiscount)
            Positioned(
              top: 9,
              left: 9,
              child: _buildDiscountBadge(),
            ),

          // =====================================================================
          // CART CONTROL
          // =====================================================================

          if (onAdd != null)
            Positioned(
              right: 9,
              bottom: 9,
              child: _buildCartControl(),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // IMAGE CONTENT
  // ===========================================================================

  Widget _buildImageContent() {
    if (!_hasImage) {
      return _buildFallbackImage();
    }

    return Image.network(
      photoUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) {
        return _buildFallbackImage();
      },
      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            _buildFallbackImage(),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // FALLBACK IMAGE
  // ===========================================================================

  Widget _buildFallbackImage() {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Icon(
        Icons.fastfood_rounded,
        size: 30,
        color: AppColors.textSecondary,
      ),
    );
  }

  // ===========================================================================
  // DISCOUNT BADGE
  // ===========================================================================

  Widget _buildDiscountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '-$discountPercentage%',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }

  // ===========================================================================
  // CART CONTROL
  // ===========================================================================

  Widget _buildCartControl() {
    final currentQuantity = quantity ?? 0;

    // -------------------------------------------------------------------------
    // ADD BUTTON
    // -------------------------------------------------------------------------

    if (currentQuantity <= 0) {
      return Material(
        color: AppColors.primary,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.18),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onAdd,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.add_rounded,
              color: AppColors.textOnPrimary,
              size: 23,
            ),
          ),
        ),
      );
    }

    // -------------------------------------------------------------------------
    // QUANTITY CONTROL
    // -------------------------------------------------------------------------

    return Material(
      color: AppColors.background,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.16),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _cartButton(
              icon: Icons.remove_rounded,
              onTap: onRemove,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
              ),
              child: Text(
                '$currentQuantity',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
            _cartButton(
              icon: Icons.add_rounded,
              onTap: onAdd,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.primaryLight,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 27,
          height: 27,
          child: Icon(
            icon,
            size: 15,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PRICE
  // ===========================================================================

  Widget _buildPrice() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              price.toStringAsFixed(0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.priceMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 15.5,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              'ل.س',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 9,
              ),
            ),
          ],
        ),

        // =======================================================================
        // OLD PRICE
        // =======================================================================

        if (_hasDiscount) ...[
          const SizedBox(height: 1),
          Text(
            '${oldPrice!.toStringAsFixed(0)} ل.س',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
              fontSize: 9,
              decoration: TextDecoration.lineThrough,
              decorationThickness: 1.1,
            ),
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // DETAILS / ARROW BUTTON
  // ===========================================================================

  Widget _buildDetailsButton() {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}