import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Bloc-blind.
/// The parent provides the current quantity and handles cart actions.
class PopularDishCard extends StatelessWidget {
  const PopularDishCard({
    super.key,
    required this.photoUrl,
    required this.dishNameAr,
    required this.businessNameAr,
    required this.dishPrice,
    required this.onTap,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final String photoUrl;
  final String dishNameAr;
  final String businessNameAr;
  final double dishPrice;

  final GestureTapCallback onTap;

  /// Current quantity of this item in the cart.
  final int quantity;

  /// Called when + is pressed.
  final VoidCallback onAdd;

  /// Called when - is pressed.
  final VoidCallback onRemove;

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
            // ================= IMAGE =================
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

            // ================= INFO =================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dish name + restaurant
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 2),
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
                ),

                const SizedBox(width: AppSpacing.xs),

                // Price
                Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Price with Currency Label
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: dishPrice.toStringAsFixed(0),
                                style: AppTextStyles.priceMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              TextSpan(
                                text: ' ل.س',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
 ]

                    )
              ],
            ),

            const SizedBox(height: AppSpacing.xs),

            // ================= CART CONTROL =================
            Align(
              alignment: Alignment.centerRight,
              child: quantity == 0
                  ? _AddButton(
                      onPressed: onAdd,
                    )
                  : _QuantityControl(
                      quantity: quantity,
                      onAdd: onAdd,
                      onRemove: onRemove,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ADD BUTTON
// ============================================================

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: const SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            Icons.add,
            color: AppColors.textOnPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// QUANTITY CONTROL
// ============================================================

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Counter
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SmallButton(
                icon: Icons.remove,
                onPressed: onRemove,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '$quantity',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              _SmallButton(
                icon: Icons.add,
                onPressed: onAdd,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SMALL + / - BUTTON
// ============================================================

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          icon,
          size: 15,
          color: AppColors.primary,
        ),
      ),
    );
  }
}