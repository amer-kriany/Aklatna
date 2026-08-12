import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Modern, highly-flexible menu item card with optional cart controls.
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
    this.onTap,  this.oldPrice,  this.discountPercentage,
  });

  final String? photoUrl;
  final String nameAr;
  final String? businessNameAr;
  final double price;
  final double? oldPrice;
  final int? discountPercentage;

  /// Current quantity of this item in the cart (optional).
  final int? quantity;

  /// Called when + is pressed (optional - if omitted, card renders without cart controls).
  final VoidCallback? onAdd;

  /// Called when - is pressed (optional).
  final VoidCallback? onRemove;

  /// Tap callback for navigating or opening item details.
  final VoidCallback? onTap;

  bool get _hasValidPhotoUrl {
    if (photoUrl == null || photoUrl!.trim().isEmpty) return false;
    final uri = Uri.tryParse(photoUrl!.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final hasBusinessName =
        businessNameAr != null && businessNameAr!.trim().isNotEmpty;
    final currentQuantity = quantity ?? 0;
    final hasCartActions = onAdd != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ================= IMAGE SECTION (ASPECT RATIO BASED) =================
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: _hasValidPhotoUrl
                      ? Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackImage(),
                        )
                      : _buildFallbackImage(),
                ),
              ),

              // ================= DETAILS SECTION =================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top details (Name & Business)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Dish Name
                          Text(
                            nameAr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),

                          // Restaurant / Business Name
                          if (hasBusinessName) ...[
                            const SizedBox(height: 2),
                            Text(
                              businessNameAr!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Bottom actions (Price + Cart Controls)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Price with Currency Label
                          // Price with Currency Label (+ discount if present)
Flexible(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (oldPrice != null && discountPercentage != null && discountPercentage! > 0) ...[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              oldPrice!.toStringAsFixed(0),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                decoration: TextDecoration.lineThrough,
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '-$discountPercentage%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
      ],
      RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: price.toStringAsFixed(0),
              style: AppTextStyles.priceMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: ' ل.س',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

                          const SizedBox(width: AppSpacing.xs),

                          // Cart controls (Renders ONLY if onAdd is provided)
                          if (hasCartActions)
                            currentQuantity == 0
                                ? _AddButton(onPressed: onAdd!)
                                : _QuantityControl(
                                    quantity: currentQuantity,
                                    onAdd: onAdd!,
                                    onRemove: onRemove ?? () {},
                                  ),
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
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: const Icon(
        Icons.fastfood_rounded,
        color: AppColors.textSecondary,
        size: 28,
      ),
    );
  }
}

// ============================================================
// ADD BUTTON
// ============================================================

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: const Padding(
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.add_rounded,
            color: AppColors.textOnPrimary,
            size: 16,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SmallButton(icon: Icons.remove, onPressed: onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$quantity',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          _SmallButton(icon: Icons.add, onPressed: onAdd),
        ],
      ),
    );
  }
}

// ============================================================
// SMALL + / - BUTTON
// ============================================================

class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          icon,
          size: 13,
          color: AppColors.primary,
        ),
      ),
    );
  }
}