import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';



class MenuItemGridCard extends StatelessWidget {
  const MenuItemGridCard({
    super.key,
    required this.photoUrl,
    required this.nameAr,
    required this.price,
    required this.onAdd,
    this.onTap,
  });

  final String? photoUrl;
  final String nameAr;
  final double price;
  final VoidCallback onAdd;
  final VoidCallback? onTap;

  bool get _hasValidPhotoUrl {
    final url = photoUrl ?? '';
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AspectRatio(
                aspectRatio: 1.3,
                child: _hasValidPhotoUrl
                    ? Image.network(photoUrl!, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.surface,
                        alignment: Alignment.center,
                        child: const Icon(Icons.fastfood, color: AppColors.textSecondary),
                      ),
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              nameAr,
              style: AppTextStyles.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.xxs),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    // NOTE: raw numeric price — no currency/thousands formatting yet,
                    // same open item flagged earlier on FoodDetailsPage.
                    price.toStringAsFixed(0),
                    style: AppTextStyles.priceMedium,
                  ),
                ),
                InkWell(
  onTap: () {
    // TODO(Amer): wire to CartBloc — add(itemId, nameAr, price, businessId).
    // Must check cart is empty OR already scoped to this businessId before
    // adding (cart is locked to one restaurant at a time per your rules) —
    // if it holds items from a different business, this needs to prompt
    // "clear cart and start new order?" rather than silently mixing.
  },
  borderRadius: BorderRadius.circular(AppRadius.full),
  child: Container(
    width: AppSizes.iconLg,
    height: AppSizes.iconLg,
    decoration: const BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.add,
      color: AppColors.textOnPrimary,
      size: AppSizes.iconSm,
    ),
  ),
),
              ],
            ),
          ],
        ),
      ),
    );
  }
}