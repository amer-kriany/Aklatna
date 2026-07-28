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
    this.onTap,
  });

  final String? photoUrl;
  final String nameAr;
  final String? businessNameAr;
  final double price;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ================= IMAGE SECTION =================
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                child: _hasValidPhotoUrl
                    ? Image.network(
                        photoUrl!,
                        height: 115,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackImage(),
                      )
                    : _buildFallbackImage(),
              ),

              // ================= DETAILS SECTION =================
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Dish Name
                    Text(
                      nameAr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

                    const SizedBox(height: AppSpacing.xs),

                    // Price + Optional Cart Action Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Price with Currency Label
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: price.toStringAsFixed(0),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      height: 115,
      width: double.infinity,
      color: AppColors.surface,
      alignment: Alignment.center,
      child: const Icon(
        Icons.fastfood_rounded,
        color: AppColors.textSecondary,
        size: 32,
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
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.add_rounded,
            color: AppColors.textOnPrimary,
            size: 18,
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
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SmallButton(icon: Icons.remove, onPressed: onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$quantity',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
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
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 22,
        height: 22,
        child: Icon(icon, size: 14, color: AppColors.primary),
      ),
    );
  }
}
