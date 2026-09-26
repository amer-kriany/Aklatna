
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

  bool get _hasDiscount =>
      oldPrice != null &&
      discountPercentage != null &&
      discountPercentage! > 0;

  bool get _hasImage =>
      photoUrl != null && photoUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border.withOpacity(0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImage(),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  11,
                  10,
                  11,
                  11,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================================
                    // FOOD NAME
                    // ==========================================================

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
                          fontSize: 14,
                          height: 1.25,
                        ),
                      ),
                    ),

                    // ==========================================================
                    // RESTAURANT
                    // ==========================================================

                    if (businessNameAr != null &&
                        businessNameAr!.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              size: 13,
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
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),

                    // ==========================================================
                    // PRICE + CART
                    // ==========================================================

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Cart action
                        if (onAdd != null) ...[
                          _buildCartControl(),
                          const SizedBox(width: 7),
                        ],

                        Expanded(
                          child: _buildPrice(),
                        ),
                      ],
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

  // ==========================================================================
  // IMAGE
  // ==========================================================================

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 1.08,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImageContent(),

          // Bottom subtle gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 45,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.12),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Discount
          if (_hasDiscount)
            Positioned(
              top: 9,
              left: 9,
              child: _buildDiscountBadge(),
            ),
        ],
      ),
    );
  }

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
      loadingBuilder: (context, child, loadingProgress) {
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

  Widget _buildFallbackImage() {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Icon(
        Icons.fastfood_rounded,
        size: 32,
        color: AppColors.primary,
      ),
    );
  }

  // ==========================================================================
  // DISCOUNT
  // ==========================================================================

  Widget _buildDiscountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        '$discountPercentage% خصم',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }

  // ==========================================================================
  // CART CONTROL
  // ==========================================================================

  Widget _buildCartControl() {
    final currentQuantity = quantity ?? 0;

    // First add
    if (currentQuantity <= 0) {
      return Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.15),
        child: InkWell(
          onTap: onAdd,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              Icons.add_rounded,
              color: AppColors.textOnPrimary,
              size: 22,
            ),
          ),
        ),
      );
    }

    // Quantity
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _quantityButton(
            icon: Icons.add_rounded,
            onTap: onAdd,
            filled: true,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$currentQuantity',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),

          _quantityButton(
            icon: Icons.remove_rounded,
            onTap: onRemove,
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onTap,
    bool filled = false,
  }) {
    return Material(
      color: filled ? AppColors.primary : AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            icon,
            size: 16,
            color: filled
                ? AppColors.textOnPrimary
                : AppColors.primary,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // PRICE
  // ==========================================================================

  Widget _buildPrice() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${price.toStringAsFixed(0)}',
                style: AppTextStyles.priceMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                'ل.س',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                ),
              ),
            ],
          ),

          if (_hasDiscount) ...[
            const SizedBox(height: 1),
            Text(
              '${oldPrice!.toStringAsFixed(0)} ل.س',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
                fontSize: 9,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

