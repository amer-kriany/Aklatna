import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/theme/app_colors.dart';

import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_state.dart';

import 'package:aklatna/features/favorit/presentation/bloc/favorite_bloc.dart';

import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/home/presentation/pages/PeriodicRebuildMixin.dart';
import 'package:aklatna/features/home/presentation/widgets/businesses/BusinessCategoryChips.dart';
import 'package:aklatna/features/home/presentation/widgets/businesses/MenuItemGridCard.dart';
import 'package:aklatna/features/home/presentation/widgets/businesses/businessDetailsInfo.dart';

import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';
import 'package:aklatna/features/promotions/presentaion/bloc/promotions_bloc.dart';
import 'package:aklatna/features/promotions/presentaion/widgets/promotionCard.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/widgets/page_skeletons.dart';

class BusinessDetailsPage extends StatefulWidget {
  const BusinessDetailsPage({
    super.key,
    required this.businessId,
  });

  final String businessId;

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage>
    with PeriodicRebuildMixin {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    context.read<BusinessBloc>().add(
          GetBusinessById(id: widget.businessId),
        );

    context.read<MenuBloc>().add(
          GetMenuForBusiness(
            businessId: widget.businessId,
          ),
        );

    context.read<PromotionsBloc>().add(
          LoadPromotionsEvent(),
        );

    final userId =
        Supabase.instance.client.auth.currentUser?.id;

    if (userId != null) {
      context.read<FavoriteBloc>().add(
            LoadFavoritesEvent(userId: userId),
          );
    }

    startPeriodicRebuild();
  }

  void _onToggleFavorite() {
    final userId =
        Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء تسجيل الدخول لإضافة المفضلة',
          ),
        ),
      );
      return;
    }

    context.read<FavoriteBloc>().add(
          ToggleFavoriteEvent(
            userId: userId,
            businessId: widget.businessId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<BusinessBloc, BusinessState>(
          builder: (context, businessState) {
            if (businessState is BusinessLoading ||
                businessState is BusinessInitial) {
              return const DashboardSkeleton();
            }

            if (businessState is BusinessError) {
              return Center(
                child: Text(businessState.message),
              );
            }

            if (businessState is! BusinessDetailLoaded) {
              return const SizedBox.shrink();
            }

            final business = businessState.business;

            return Column(
              children: [
                _buildHero(
                  context,
                  business,
                ),

                Expanded(
                  child: BlocBuilder<MenuBloc, MenuState>(
                    builder: (context, menuState) {
                      if (menuState is MenuLoading) {
                        return const ListSkeleton(
                          itemCount: 6,
                          showLeadingCircle: false,
                        );
                      }

                      if (menuState is MenuError) {
                        return Center(
                          child: Text(menuState.message),
                        );
                      }

                      if (menuState is! MenuByBusinessLoaded) {
                        return const SizedBox.shrink();
                      }

                      if (menuState.categories.isEmpty) {
                        return const Center(
                          child: Text(
                            'لا يوجد قائمة طعام حالياً',
                          ),
                        );
                      }

                      if (_selectedIndex >=
                          menuState.categories.length) {
                        _selectedIndex = 0;
                      }

                      final categoryNames =
                          menuState.categories
                              .map((category) => category.nameAr)
                              .toList();

                      final selectedCategory =
                          menuState.categories[_selectedIndex];

                      final itemsInCategory =
                          menuState.items
                              .where(
                                (item) =>
                                    item.categoryId ==
                                    selectedCategory.id,
                              )
                              .toList();

                      final promoState =
                          context.watch<PromotionsBloc>().state;

                      final Map<String, PromotionEntity>
                          promoByItemId = {
                        if (promoState is PromotionsLoaded)
                          for (final promotion
                              in promoState.promotions)
                            if (promotion.businessId ==
                                    widget.businessId &&
                                promotion.menuItemId != null)
                              promotion.menuItemId!: promotion,
                      };

                      final businessPromotions =
                          promoState is PromotionsLoaded
                              ? promoState.promotions
                                  .where(
                                    (promotion) =>
                                        promotion.businessId ==
                                        widget.businessId,
                                  )
                                  .toList()
                              : <PromotionEntity>[];

                      return _buildContent(
                        context,
                        business,
                        categoryNames,
                        selectedCategory.nameAr,
                        itemsInCategory,
                        menuState,
                        promoState,
                        businessPromotions,
                        promoByItemId,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildCartBar(),
    );
  }

  Widget _buildHero(
    BuildContext context,
    dynamic business,
  ) {
    final hasImage =
        business.coverUrl != null &&
        business.coverUrl!.trim().isNotEmpty;

    return SizedBox(
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 245,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  hasImage
                      ? Image.network(
                          business.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) =>
                                  _buildHeroFallback(),
                        )
                      : _buildHeroFallback(),

                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.30),
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 16,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                _buildHeroButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                _buildFavoriteButton(),
              ],
            ),
          ),

          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: BusinessDetailsInfo(
                nameAr: business.nameAr,
                rating: business.rating,
                description:
                    business.description ?? '',
                isOpen: business.isOpen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroFallback() {
    return Container(
      color: AppColors.primaryLight,
      child: Center(
        child: Icon(
          Icons.storefront_rounded,
          size: 60,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildHeroButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.94),
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favoriteState) {
        final isFavorite =
            favoriteState is FavoriteLoaded &&
            favoriteState.favoriteIds.contains(
              widget.businessId,
            );

        return Material(
          color: Colors.white.withOpacity(0.94),
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _onToggleFavorite,
            child: SizedBox(
              width: 44,
              height: 44,
              child: AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 180,
                ),
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(isFavorite),
                  color: isFavorite
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  size: 22,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    dynamic business,
    List<String> categoryNames,
    String selectedCategoryName,
    List<dynamic> itemsInCategory,
    MenuState menuState,
    PromotionsState promoState,
    List<PromotionEntity> businessPromotions,
    Map<String, PromotionEntity> promoByItemId,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),

          if (promoState is PromotionsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: SizedBox(
                height: 100,
                child: ListSkeleton(
                  itemCount: 2,
                  showLeadingCircle: false,
                ),
              ),
            )
          else if (businessPromotions.isNotEmpty)
            _buildPromotionsSection(
              context,
              businessPromotions,
            ),

          const SizedBox(height: AppSpacing.xs),

          _buildCategorySection(
            categoryNames,
          ),

          const SizedBox(height: AppSpacing.lg),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedCategoryName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${itemsInCategory.length} أطباق',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color:
                                  AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          itemsInCategory.isEmpty
              ? _buildEmptyCategory()
              : BlocBuilder<CartBloc, CartState>(
                  builder: (
                    context,
                    cartState,
                  ) {
                    return _buildFoodRows(
                      context,
                      itemsInCategory,
                      cartState,
                      business,
                      promoByItemId,
                    );
                  },
                ),

          const SizedBox(height: 110),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    List<String> categoryNames,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.5),
          ),
        ),
      ),
      child: BusinessCategoryChips(
        categoryNames: categoryNames,
        selectedIndex: _selectedIndex,
        onSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildEmptyCategory() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 60,
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'لا توجد أطباق هنا حالياً',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'جرّب قسمًا آخر',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionsSection(
    BuildContext context,
    List<PromotionEntity> promotions,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_offer_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'عروض اليوم',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        SizedBox(
          height: PromotionCard.cardHeight,
          child: ListView.separated(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
            ),
            scrollDirection: Axis.horizontal,
            physics:
                const BouncingScrollPhysics(),
            itemCount: promotions.length,
            separatorBuilder: (_, __) =>
                const SizedBox(
              width: AppSpacing.sm,
            ),
            itemBuilder: (context, index) {
              final promotion =
                  promotions[index];

              return PromotionCard(
                width: 190,
                businessName:
                    promotion.businessName,
                coverUrl:
                    promotion.photoUrl,
                itemName:
                    promotion.itemName,
                label:
                    promotion.label,
                menuItemId:
                    promotion.menuItemId,
                discountPercentage:
                    promotion.discountPercentage,
                oldPrice:
                    promotion.oldPrice?.toDouble(),
                newPrice:
                    promotion.newPrice?.toDouble(),
                onTap: () {
                  if (promotion.menuItemId != null) {
                    context.push(
                      '/food/${promotion.menuItemId}',
                    );
                  } else {
                    context.push(
                      '/promotion-details',
                      extra: promotion,
                    );
                  }
                },
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildFoodRows(
    BuildContext context,
    List<dynamic> items,
    CartState cartState,
    dynamic business,
    Map<String, PromotionEntity> promoByItemId,
  ) {
    final rows = <Widget>[];

    const columns = 2;

    for (int i = 0; i < items.length; i += columns) {
      final rowItems =
          items.skip(i).take(columns).toList();

      final children = <Widget>[];

      for (
        int column = 0;
        column < columns;
        column++
      ) {
        if (column < rowItems.length) {
          final item = rowItems[column];

          final promo =
              promoByItemId[item.id];

          final effectivePrice =
              promo?.newPrice ?? item.price;

          final matchingItemIndex =
              cartState.items.indexWhere(
            (element) =>
                element.itemId == item.id,
          );

          final itemQuantity =
              matchingItemIndex != -1
                  ? cartState
                      .items[matchingItemIndex]
                      .quantity
                  : 0;

          children.add(
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: column == 0
                      ? AppSpacing.lg
                      : AppSpacing.xs,
                  right: column == 1
                      ? AppSpacing.lg
                      : AppSpacing.xs,
                  bottom: AppSpacing.md,
                ),
                child: MenuItemGridCard(
                  photoUrl: item.photoUrl,
                  nameAr: item.nameAr,
                  price: effectivePrice,
                  oldPrice: promo?.oldPrice,
                  discountPercentage:
                      promo?.discountPercentage,
                  quantity: itemQuantity,
                  onTap: () {
                    context.push(
                      '/food/${item.id}',
                    );
                  },
                  onAdd: () {
                    context
                        .read<CartBloc>()
                        .add(
                          AddItemEvent(
                            item: CartItem(
                              itemId: item.id,
                              nameAr: item.nameAr,
                              description:
                                  item.description ??
                                      '',
                              price:
                                  effectivePrice,
                              quantity: 1,
                              businessId:
                                  item.businessId,
                            ),
                            businessName:
                                business.nameAr,
                            businessLogo:
                                business.logoUrl,
                          ),
                        );
                  },
                  onRemove: () {
                    context
                        .read<CartBloc>()
                        .add(
                          RemoveItemEvent(
                            itemId: item.id,
                          ),
                        );
                  },
                ),
              ),
            ),
          );
        } else {
          children.add(
            const Expanded(
              child: SizedBox(),
            ),
          );
        }
      }

      rows.add(
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: children,
        ),
      );
    }

    return Column(
      children: rows,
    );
  }

  Widget _buildCartBar() {
  return BlocBuilder<CartBloc, CartState>(
    builder: (context, cartState) {
      if (cartState.items.isEmpty) {
        return const SizedBox.shrink();
      }

      final totalQuantity = cartState.items.fold<int>(
        0,
        (sum, item) => sum + item.quantity,
      );

      final totalPrice = cartState.items.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );

      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            elevation: 10,
            shadowColor: AppColors.primary.withOpacity(0.25),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                context.go('/cart');
              },
              child: SizedBox(
                height: 58,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      // CART ICON + BADGE
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),

                          Positioned(
                            right: -3,
                            top: -4,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$totalQuantity',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 10),

                      // CTA
                      const Expanded(
                        child: Text(
                          'عرض السلة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      // TOTAL
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'الإجمالي',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.70),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${totalPrice.toStringAsFixed(0)} ل.س',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 8),

                      const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
}