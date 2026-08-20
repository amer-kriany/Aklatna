import 'package:aklatna/features/addOnes/domain/enitity/addOnesEntity.dart';
import 'package:aklatna/features/addOnes/presentation/bloc/add_ones_bloc.dart';
import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:aklatna/features/menu/presentation/widgets/AddToCartSection.dart';
import 'package:aklatna/features/menu/presentation/widgets/FoodDetailsImage.dart';
import 'package:aklatna/features/menu/presentation/widgets/FoodDetailsInfo.dart';
import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';
import 'package:aklatna/features/promotions/presentaion/bloc/promotions_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_skeletons.dart';
import '../../../../core/widgets/skeleton.dart';

class Foodetailspage extends StatefulWidget {
  final String itemId;
  const Foodetailspage({super.key, required this.itemId});

  @override
  State<Foodetailspage> createState() => _FoodetailspageState();
}

class _FoodetailspageState extends State<Foodetailspage> {
  int _quantity = 1;
  final Set<String> _selectedAddonIds = {};
  final TextEditingController _noteController = TextEditingController();
  bool _businessFetchTriggered = false;

  @override
  void initState() {
    context.read<MenuBloc>().add(GetMenu(id: widget.itemId));
    context.read<AddonBloc>().add(GetAddonsEvent(itemId: widget.itemId));
    super.initState();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  double _addonsTotal(List<AddonEntity> addons) => addons
      .where((a) => _selectedAddonIds.contains(a.id))
      .fold(0.0, (sum, a) => sum + a.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<MenuBloc, MenuState>(
          builder: (context, state) {
            if (state is MenuLoading) {
              return const DashboardSkeleton();
            }
            if (state is MenuError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "food not found",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            }
            if (state is MenuLoaded) {
              if (!_businessFetchTriggered) {
                _businessFetchTriggered = true;
                context.read<BusinessBloc>().add(
                  GetBusinessById(id: state.item.businessId),
                );
              }

              // ============================================================
              // PROMOTION LOOKUP
              // ============================================================

              final promoState = context.watch<PromotionsBloc>().state;

              PromotionEntity? matchingPromo;
              if (promoState is PromotionsLoaded) {
                for (final p in promoState.promotions) {
                  if (p.menuItemId == state.item.id) {
                    matchingPromo = p;
                    break;
                  }
                }
              }

              final effectivePrice =
                  matchingPromo?.newPrice ?? state.item.price;

              return BlocBuilder<AddonBloc, AddOnesState>(
                builder: (context, addonState) {
                  final addons = addonState is AddonLoaded
                      ? addonState.addons
                      : <AddonEntity>[];
                  final addonsTotal = _addonsTotal(addons);

                  return BlocBuilder<BusinessBloc, BusinessState>(
                    builder: (context, businessState) {
                      final business = businessState is BusinessDetailLoaded
                          ? businessState.business
                          : null;

                      return Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  FoodDetailsImage(
                                    imageUrl: state.item.photoUrl,
                                    onBack: () => Navigator.pop(context),
                                  
                                  ),

                                  if (business != null)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.lg,
                                        vertical: AppSpacing.sm,
                                      ),
                                      child: InkWell(
                                        onTap: () => context.push(
                                          '/business/${business.id}',
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md,
                                            vertical: AppSpacing.sm,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.md,
                                            ),
                                            border: Border.all(
                                              color: AppColors.border,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        AppRadius.sm,
                                                      ),
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child:
                                                    business.logoUrl != null &&
                                                        business
                                                            .logoUrl!
                                                            .isNotEmpty
                                                    ? Image.network(
                                                        business.logoUrl!,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .restaurant_rounded,
                                                        size: 18,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.sm,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  business.nameAr,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTextStyles
                                                      .bodyMedium
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
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

                                  const SizedBox(height: AppSpacing.lg),

                                  FoodDetailsInfo(
                                    title: state.item.nameAr,
                                    category: state.category.nameAr,
                                    description: state.item.description ?? '',
                                  ),

                                  // ============================================================
                                  // PROMO PRICE ROW (لو في عرض)
                                  // ============================================================

                                  if (matchingPromo != null &&
                                      matchingPromo.oldPrice != null)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.lg,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${matchingPromo.oldPrice!.toStringAsFixed(0)} ل.س',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.xs),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                AppRadius.sm,
                                              ),
                                            ),
                                            child: Text(
                                              '-${matchingPromo.discountPercentage}%',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: AppColors.textOnPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  if (addonState is AddonLoading)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSpacing.lg,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: AppSpacing.sm),
                                          Skeleton(
                                            width: double.infinity,
                                            height: 14,
                                            radius: AppRadius.sm,
                                          ),
                                          SizedBox(height: AppSpacing.sm),
                                          Skeleton(
                                            width: 220,
                                            height: 14,
                                            radius: AppRadius.sm,
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (addons.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.lg,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: AppSpacing.lg),
                                          Text(
                                            'إضافات',
                                            style: AppTextStyles.h4,
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          ...addons.map(
                                            (addon) => CheckboxListTile(
                                              contentPadding: EdgeInsets.zero,
                                              value: _selectedAddonIds.contains(
                                                addon.id,
                                              ),
                                              activeColor: AppColors.primary,
                                              title: Text(
                                                addon.name,
                                                style: AppTextStyles.bodyMedium,
                                              ),
                                              secondary: Text(
                                                '+${addon.price.toStringAsFixed(0)}',
                                                style:
                                                    AppTextStyles.priceMedium,
                                              ),
                                              onChanged: (checked) {
                                                setState(() {
                                                  if (checked == true) {
                                                    _selectedAddonIds.add(
                                                      addon.id,
                                                    );
                                                  } else {
                                                    _selectedAddonIds.remove(
                                                      addon.id,
                                                    );
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: AppSpacing.lg),
                                        Text(
                                          'ملاحظات',
                                          style: AppTextStyles.h4,
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        TextField(
                                          controller: _noteController,
                                          maxLines: 2,
                                          decoration: const InputDecoration(
                                            hintText: 'مثال: بدون بصل',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                ],
                              ),
                            ),
                          ),
                          AddToCartSection(
                            price:
                                ((effectivePrice + addonsTotal) * _quantity)
                                    .toString(),
                            quantity: _quantity,
                            onIncrement: () => setState(() => _quantity++),
                            onDecrement: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                            onAddToCart: () {
                              final selectedAddons = addons
                                  .where(
                                    (a) => _selectedAddonIds.contains(a.id),
                                  )
                                  .map(
                                    (a) => {
                                      'id': a.id,
                                      'name': a.name,
                                      'price': a.price,
                                    },
                                  )
                                  .toList();

                              context.read<CartBloc>().add(
                                AddItemEvent(
                                  item: CartItem(
                                    itemId: state.item.id,
                                    nameAr: state.item.nameAr,
                                    description: state.item.description ?? '',
                                    photoUrl: state.item.photoUrl,
                                    price: effectivePrice + addonsTotal,
                                    quantity: _quantity,
                                    businessId: state.item.businessId,
                                    note: _noteController.text.trim(),
                                    selectedAddons: selectedAddons,
                                  ),
                                  businessName: business?.nameAr,
                                  businessLogo: business?.logoUrl,
                                ),
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}