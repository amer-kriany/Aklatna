import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../menu/presentation/widgets/AddToCartSection.dart';
import '../../../menu/presentation/widgets/FoodDetailsImage.dart';

class PromotionDetailsPage extends StatefulWidget {
  const PromotionDetailsPage({super.key, required this.promotion});

  final PromotionEntity promotion;

  @override
  State<PromotionDetailsPage> createState() => _PromotionDetailsPageState();
}

class _PromotionDetailsPageState extends State<PromotionDetailsPage> {
  int _quantity = 1;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promo = widget.promotion;
    final price = promo.newPrice ?? 0;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FoodDetailsImage(
                      imageUrl: promo.photoUrl,
                      onBack: () => Navigator.pop(context),
                      onFavorite: () {},
                      isFavorite: false,
                    ),

                    // ============================================================
                    // BUSINESS LINK
                    // ============================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      child: InkWell(
                        onTap: () => context.push('/business/${promo.businessId}'),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.restaurant_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  promo.businessName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_left_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ============================================================
                    // NAME
                    // ============================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Text(
                        promo.itemName,
                        style: AppTextStyles.h3,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // ============================================================
                    // PRICE ROW (شطب + بادج) — فقط لو في خصم فعلي
                    // ============================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Row(
                        children: [
                          if (promo.oldPrice != null && promo.discountPercentage > 0) ...[
                            Text(
                              '${promo.oldPrice!.toStringAsFixed(0)} ل.س',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Text(
                            '${price.toStringAsFixed(0)} ل.س',
                            style: AppTextStyles.priceMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (promo.discountPercentage > 0) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                '-${promo.discountPercentage}%',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ============================================================
                    // DESCRIPTION
                    // ============================================================
                    if (promo.description != null && promo.description!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          0,
                        ),
                        child: Text(
                          promo.description!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                    // ============================================================
                    // NOTES
                    // ============================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          Text('ملاحظات', style: AppTextStyles.h4),
                          const SizedBox(height: AppSpacing.xs),
                          TextField(
                            controller: _noteController,
                            maxLines: 2,
                            decoration: const InputDecoration(hintText: 'مثال: بدون بصل'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // ============================================================
            // ADD TO CART
            // ============================================================
            AddToCartSection(
              price: (price * _quantity).toStringAsFixed(0),
              quantity: _quantity,
              onIncrement: () => setState(() => _quantity++),
              onDecrement: () {
                if (_quantity > 1) setState(() => _quantity--);
              },
              onAddToCart: () {
                context.read<CartBloc>().add(
                  AddItemEvent(
                    item: CartItem(
                      itemId: promo.menuItemId ?? 'promo_${promo.id}',
                      nameAr: promo.itemName,
                      description: '',
                      photoUrl: promo.photoUrl,
                      price: price,
                      quantity: _quantity,
                      businessId: promo.businessId,
                      note: _noteController.text.trim(),
                      selectedAddons: const [],
                    ),
                    businessName: promo.businessName,
                    businessLogo: null,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}