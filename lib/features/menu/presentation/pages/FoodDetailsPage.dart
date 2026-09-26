import 'package:aklatna/features/addOnes/domain/enitity/addOnesEntity.dart';
import 'package:aklatna/features/addOnes/presentation/bloc/add_ones_bloc.dart';
import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:aklatna/features/menu/presentation/widgets/FoodDetailsImage.dart';
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

  const Foodetailspage({
    super.key,
    required this.itemId,
  });

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
    super.initState();

    context.read<MenuBloc>().add(
          GetMenu(id: widget.itemId),
        );

    context.read<AddonBloc>().add(
          GetAddonsEvent(itemId: widget.itemId),
        );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  double _addonsTotal(List<AddonEntity> addons) {
    return addons
        .where((addon) => _selectedAddonIds.contains(addon.id))
        .fold(
          0.0,
          (sum, addon) => sum + addon.price,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<MenuBloc, MenuState>(
          builder: (context, state) {
            if (state is MenuLoading) {
              return const DashboardSkeleton();
            }

            if (state is MenuError) {
              return _buildError();
            }

            if (state is! MenuLoaded) {
              return const SizedBox.shrink();
            }

            if (!_businessFetchTriggered) {
              _businessFetchTriggered = true;

              context.read<BusinessBloc>().add(
                    GetBusinessById(
                      id: state.item.businessId,
                    ),
                  );
            }

            final promoState = context.watch<PromotionsBloc>().state;

            PromotionEntity? promotion;

            if (promoState is PromotionsLoaded) {
              for (final item in promoState.promotions) {
                if (item.menuItemId == state.item.id) {
                  promotion = item;
                  break;
                }
              }
            }

            final effectivePrice =
                promotion?.newPrice ?? state.item.price;

            return BlocBuilder<AddonBloc, AddOnesState>(
              builder: (context, addonState) {
                final addons = addonState is AddonLoaded
                    ? addonState.addons
                    : <AddonEntity>[];

                final addonsTotal = _addonsTotal(addons);

                return BlocBuilder<BusinessBloc, BusinessState>(
                  builder: (context, businessState) {
                    final business =
                        businessState is BusinessDetailLoaded
                            ? businessState.business
                            : null;

                    return Column(
                      children: [
                        Expanded(
                          child: CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(
                                child: FoodDetailsImage(
                                  imageUrl: state.item.photoUrl,
                                  onBack: () => Navigator.pop(context),
                                ),
                              ),

                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.lg,
                                    AppSpacing.lg,
                                    AppSpacing.lg,
                                    0,
                                  ),
                                  child: _buildFoodHeader(
                                    state,
                                    effectivePrice,
                                    promotion,
                                  ),
                                ),
                              ),

                              if (business != null)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      AppSpacing.lg,
                                      AppSpacing.lg,
                                      AppSpacing.lg,
                                      0,
                                    ),
                                    child: _buildBusinessCard(
                                      business,
                                    ),
                                  ),
                                ),

                              if (addons.isNotEmpty)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      AppSpacing.lg,
                                      AppSpacing.xl,
                                      AppSpacing.lg,
                                      0,
                                    ),
                                    child: _buildAddonsSection(
                                      addons,
                                    ),
                                  ),
                                ),

                              if (addonState is AddonLoading)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                    ),
                                    child: _buildAddonSkeleton(),
                                  ),
                                ),

                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.lg,
                                    AppSpacing.xl,
                                    AppSpacing.lg,
                                    AppSpacing.xl,
                                  ),
                                  child: _buildNotesSection(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        _buildBottomBar(
                          effectivePrice + addonsTotal,
                          business,
                          state,
                          addons,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFoodHeader(
    MenuLoaded state,
    double effectivePrice,
    PromotionEntity? promotion,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      state.item.nameAr,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    state.category.nameAr,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _buildPrice(
              effectivePrice,
              promotion,
            ),
          ],
        ),

        if (state.item.description != null &&
            state.item.description!.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              state.item.description!,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrice(
    double price,
    PromotionEntity? promotion,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${price.toStringAsFixed(0)} ل.س',
          style: AppTextStyles.priceMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        if (promotion?.oldPrice != null) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${promotion!.oldPrice!.toStringAsFixed(0)} ل.س',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(
                    AppRadius.sm,
                  ),
                ),
                child: Text(
                  '-${promotion.discountPercentage}%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBusinessCard(dynamic business) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: () {
          context.push(
            '/business/${business.id}',
          );
        },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.border.withOpacity(0.6),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: business.logoUrl != null &&
                        business.logoUrl!.isNotEmpty
                    ? Image.network(
                        business.logoUrl!,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.primary,
                      ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.nameAr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          business.rating.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'عرض المطعم',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
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
    );
  }

  Widget _buildAddonsSection(
    List<AddonEntity> addons,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'الإضافات',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              'اختياري',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          'أضف لمستك الخاصة على طلبك',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        ...addons.map(
          (addon) => _buildAddonTile(addon),
        ),
      ],
    );
  }

  Widget _buildAddonTile(
    AddonEntity addon,
  ) {
    final selected =
        _selectedAddonIds.contains(addon.id);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.xs,
      ),
      child: Material(
        color: selected
            ? AppColors.primaryLight
            : AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              if (selected) {
                _selectedAddonIds.remove(addon.id);
              } else {
                _selectedAddonIds.add(addon.id);
              }
            });
          },
          borderRadius: BorderRadius.circular(
            AppRadius.md,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
              border: Border.all(
                color: selected
                    ? AppColors.primary.withOpacity(0.35)
                    : AppColors.border.withOpacity(0.55),
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),

                const SizedBox(width: AppSpacing.sm),

                Expanded(
                  child: Text(
                    addon.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),

                Text(
                  '+${addon.price.toStringAsFixed(0)} ل.س',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاحظات على الطلب',
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'اختياري — أخبر المطعم بأي طلب خاص',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        TextField(
          controller: _noteController,
          maxLines: 3,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'مثال: بدون بصل، قليل الملح...',
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.all(
              AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
              borderSide: BorderSide(
                color: AppColors.border.withOpacity(0.7),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
              borderSide: BorderSide(
                color: AppColors.border.withOpacity(0.7),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    double unitPrice,
    dynamic business,
    MenuLoaded state,
    List<AddonEntity> addons,
  ) {
    final total =
        unitPrice * _quantity;

    return Material(
      color: AppColors.surface,
      elevation: 12,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.border.withOpacity(0.6),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(
                    AppRadius.md,
                  ),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _quantityButton(
                      icon: Icons.remove_rounded,
                      enabled: _quantity > 1,
                      onTap: () {
                        if (_quantity > 1) {
                          setState(() {
                            _quantity--;
                          });
                        }
                      },
                    ),
                    SizedBox(
                      width: 34,
                      child: Center(
                        child: Text(
                          '$_quantity',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    _quantityButton(
                      icon: Icons.add_rounded,
                      enabled: true,
                      onTap: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(
                    AppRadius.md,
                  ),
                  child: InkWell(
                    onTap: () {
                      final selectedAddons = addons
                          .where(
                            (addon) =>
                                _selectedAddonIds
                                    .contains(addon.id),
                          )
                          .map(
                            (addon) => {
                              'id': addon.id,
                              'name': addon.name,
                              'price': addon.price,
                            },
                          )
                          .toList();

                      context.read<CartBloc>().add(
                            AddItemEvent(
                              item: CartItem(
                                itemId: state.item.id,
                                nameAr: state.item.nameAr,
                                description:
                                    state.item.description ?? '',
                                photoUrl:
                                    state.item.photoUrl,
                                price: unitPrice,
                                quantity: _quantity,
                                businessId:
                                    state.item.businessId,
                                note:
                                    _noteController.text.trim(),
                                selectedAddons:
                                    selectedAddons,
                              ),
                              businessName:
                                  business?.nameAr,
                              businessLogo:
                                  business?.logoUrl,
                            ),
                          );

                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(
                      AppRadius.md,
                    ),
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                            size: 19,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'أضف للسلة',
                            style:
                                AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 18,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${total.toStringAsFixed(0)} ل.س',
                            style:
                                AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        child: SizedBox(
          width: 38,
          height: 46,
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? AppColors.primary
                : AppColors.textHint,
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'تعذر تحميل الطبق',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'لم نتمكن من العثور على هذا الطبق.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildAddonSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        const Skeleton(
          width: 100,
          height: 20,
          radius: AppRadius.sm,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(
              bottom: AppSpacing.xs,
            ),
            child: Skeleton(
              width: double.infinity,
              height: 56,
              radius: AppRadius.md,
            ),
          ),
        ),
      ],
    );
  }
}