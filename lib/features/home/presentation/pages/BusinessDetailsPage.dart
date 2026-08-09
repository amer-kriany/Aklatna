import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/core/utils/delivery_price_utils.dart';
import 'package:aklatna/core/utils/distance_utils.dart';

import 'package:aklatna/features/addresses/domain/entity/addressEntity.dart';
import 'package:aklatna/features/addresses/presentation/bloc/address_bloc.dart';

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
  State<BusinessDetailsPage> createState() =>
      _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage>
    with PeriodicRebuildMixin {
  int _selectedIndex = 0;

  // ============================================================
  // DELIVERY FEE
  // ============================================================

  String _deliveryFeeText(
    BuildContext context,
    BusinessDetailLoaded businessState,
  ) {
    final addressState = context.watch<AddressBloc>().state;

    if (addressState is! AddressLoaded) {
      return 'غير متوفر';
    }

    AddressEntity? defaultAddress;

    for (final address in addressState.addresses) {
      if (address.isDefault) {
        defaultAddress = address;
        break;
      }
    }

    if (defaultAddress == null) {
      return 'غير متوفر';
    }

    final business = businessState.business;

    final distanceKm = DistanceUtils.calculateDistanceKm(
      customerLatitude: defaultAddress.latitude,
      customerLongitude: defaultAddress.longitude,
      restaurantLatitude: business.latitude,
      restaurantLongitude: business.longitude,
    );

    final price = DeliveryPriceUtils.calculateDeliveryPrice(
      distanceKm,
    );

    return DeliveryPriceUtils.formatDeliveryPrice(price);
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // ============================================================
    // BUSINESS
    // ============================================================

    context.read<BusinessBloc>().add(
      GetBusinessById(
        id: widget.businessId,
      ),
    );

    // ============================================================
    // MENU
    // ============================================================

    context.read<MenuBloc>().add(
      GetMenuForBusiness(
        businessId: widget.businessId,
      ),
    );

    // ============================================================
    // PROMOTIONS
    // ============================================================

    context.read<PromotionsBloc>().add(
      LoadPromotionsEvent(),
    );

    // ============================================================
    // USER DATA
    // ============================================================

    final userId =
        Supabase.instance.client.auth.currentUser?.id;

    if (userId != null) {
      // FAVORITES
      context.read<FavoriteBloc>().add(
        LoadFavoritesEvent(
          userId: userId,
        ),
      );

      // ADDRESSES
      if (context.read<AddressBloc>().state is AddressInitial) {
        context.read<AddressBloc>().add(
          LoadAddressesEvent(
            userId: userId,
          ),
        );
      }
    }

    startPeriodicRebuild();
  }

  // ============================================================
  // FAVORITE
  // ============================================================

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<BusinessBloc, BusinessState>(
          builder: (context, businessState) {
            // ========================================================
            // LOADING
            // ========================================================

            if (businessState is BusinessLoading ||
                businessState is BusinessInitial) {
              return const DashboardSkeleton();
            }

            // ========================================================
            // ERROR
            // ========================================================

            if (businessState is BusinessError) {
              return Center(
                child: Text(
                  businessState.message,
                ),
              );
            }

            // ========================================================
            // INVALID STATE
            // ========================================================

            if (businessState is! BusinessDetailLoaded) {
              return const SizedBox.shrink();
            }

            final business = businessState.business;

            return Column(
              children: [
                // ======================================================
                // HEADER IMAGE
                // ======================================================

                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // ==================================================
                      // COVER
                      // ==================================================

                      Positioned.fill(
                        child:
                            business.coverUrl != null &&
                                business.coverUrl!.isNotEmpty
                            ? Image.network(
                                business.coverUrl!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return Container(
                                        color: const Color(
                                          0xFFEDEDEF,
                                        ),
                                      );
                                    },
                              )
                            : Container(
                                color: const Color(
                                  0xFFEDEDEF,
                                ),
                              ),
                      ),

                      // ==================================================
                      // HEADER BUTTONS
                      // ==================================================

                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            AppSpacing.lg,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              // ==================================================
                              // BACK BUTTON
                              // ==================================================

                              Material(
                                color: Colors.white,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder:
                                      const CircleBorder(),
                                  onTap: () =>
                                      Navigator.pop(context),
                                  child: const SizedBox(
                                    width: 42,
                                    height: 42,
                                    child: Icon(
                                      Icons
                                          .arrow_back_ios_new_rounded,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),

                              // ==================================================
                              // FAVORITE BUTTON
                              // ==================================================

                              BlocBuilder<
                                FavoriteBloc,
                                FavoriteState
                              >(
                                builder:
                                    (
                                      context,
                                      favoriteState,
                                    ) {
                                      final isFavorite =
                                          favoriteState
                                              is FavoriteLoaded &&
                                          favoriteState.favoriteIds
                                              .contains(
                                                widget.businessId,
                                              );

                                      return Material(
                                        color: Colors.white,
                                        shape:
                                            const CircleBorder(),
                                        child: InkWell(
                                          customBorder:
                                              const CircleBorder(),
                                          onTap:
                                              _onToggleFavorite,
                                          child: SizedBox(
                                            width: 42,
                                            height: 42,
                                            child: Icon(
                                              isFavorite
                                                  ? Icons
                                                        .favorite_rounded
                                                  : Icons
                                                        .favorite_border_rounded,
                                              color: isFavorite
                                                  ? AppColors
                                                        .primary
                                                  : Colors
                                                        .black87,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                // ========================================================
                // BUSINESS INFO
                // ========================================================

                BusinessDetailsInfo(
                  nameAr: business.nameAr,
                  rating: business.rating,
                  description:
                      business.description ?? '',
                  isOpen: business.isOpen,
                  deliveryFeeText:
                      _deliveryFeeText(
                    context,
                    businessState,
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                // ========================================================
                // MENU + PROMOTIONS
                // ========================================================

                Expanded(
                  child: BlocBuilder<MenuBloc, MenuState>(
                    builder: (context, menuState) {
                      // ==================================================
                      // MENU LOADING
                      // ==================================================

                      if (menuState is MenuLoading) {
                        return const ListSkeleton(
                          itemCount: 6,
                          showLeadingCircle: false,
                        );
                      }

                      // ==================================================
                      // MENU ERROR
                      // ==================================================

                      if (menuState is MenuError) {
                        return Center(
                          child: Text(
                            menuState.message,
                          ),
                        );
                      }

                      // ==================================================
                      // MENU NOT LOADED
                      // ==================================================

                      if (menuState
                          is! MenuByBusinessLoaded) {
                        return const SizedBox.shrink();
                      }

                      // ==================================================
                      // EMPTY MENU
                      // ==================================================

                      if (menuState.categories.isEmpty) {
                        return const Center(
                          child: Text(
                            'لا يوجد قائمة طعام حالياً',
                          ),
                        );
                      }

                      // ==================================================
                      // CATEGORY SAFETY
                      // ==================================================

                      if (_selectedIndex >=
                          menuState.categories.length) {
                        _selectedIndex = 0;
                      }

                      final categoryNames =
                          menuState.categories
                              .map(
                                (category) =>
                                    category.nameAr,
                              )
                              .toList();

                      final selectedCategory =
                          menuState.categories[
                              _selectedIndex];

                      final itemsInCategory =
                          menuState.items
                              .where(
                                (item) =>
                                    item.categoryId ==
                                    selectedCategory.id,
                              )
                              .toList();

                      // ==================================================
                      // MAIN SCROLL
                      // ==================================================

                      return SingleChildScrollView(
                        physics:
                            const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // ==================================================
                            // PROMOTIONS
                            // ==================================================

                            BlocBuilder<
                              PromotionsBloc,
                              PromotionsState
                            >(
                              builder:
                                  (
                                    context,
                                    promoState,
                                  ) {
                                    // ==============================================
                                    // PROMOTIONS LOADING
                                    // ==============================================

                                    if (promoState
                                        is PromotionsLoading) {
                                      return const Padding(
                                        padding:
                                            EdgeInsets.symmetric(
                                          horizontal:
                                              AppSpacing.lg,
                                          vertical:
                                              AppSpacing.sm,
                                        ),
                                        child: SizedBox(
                                          height: 100,
                                          child:
                                              ListSkeleton(
                                            itemCount: 2,
                                            showLeadingCircle:
                                                false,
                                          ),
                                        ),
                                      );
                                    }

                                    // ==============================================
                                    // PROMOTIONS ERROR
                                    // ==============================================

                                    if (promoState
                                        is PromotionsError) {
                                      return const SizedBox
                                          .shrink();
                                    }

                                    // ==============================================
                                    // PROMOTIONS NOT LOADED
                                    // ==============================================

                                    if (promoState
                                        is! PromotionsLoaded) {
                                      return const SizedBox
                                          .shrink();
                                    }

                                    // ==============================================
                                    // FILTER PROMOTIONS
                                    // ONLY THIS BUSINESS
                                    // ==============================================

                                    final businessPromotions =
                                        promoState.promotions
                                            .where(
                                              (promotion) =>
                                                  promotion
                                                      .businessId ==
                                                  widget
                                                      .businessId,
                                            )
                                            .toList();

                                    // ==============================================
                                    // NO PROMOTIONS
                                    // ==============================================

                                    if (businessPromotions
                                        .isEmpty) {
                                      return const SizedBox
                                          .shrink();
                                    }

                                    // ==============================================
                                    // PROMOTIONS SECTION
                                    // ==============================================

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        // ==========================================
                                        // SECTION TITLE
                                        // ==========================================

                                        const Padding(
                                          padding:
                                              EdgeInsets
                                                  .symmetric(
                                            horizontal:
                                                AppSpacing.lg,
                                          ),
                                          child: Text(
                                            'عروض وخصومات',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                          height:
                                              AppSpacing.sm,
                                        ),

                                        // ==========================================
                                        // PROMOTION LIST
                                        // ==========================================

                                        SizedBox(
                                          height: 250,
                                          child:
                                              ListView
                                                  .separated(
                                            padding:
                                                const EdgeInsets
                                                    .only(
                                              left:
                                                  AppSpacing.lg,
                                              right:
                                                  AppSpacing.sm,
                                            ),
                                            scrollDirection:
                                                Axis.horizontal,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount:
                                                businessPromotions
                                                    .length,
                                            separatorBuilder:
                                                (
                                                  context,
                                                  index,
                                                ) =>
                                                    const SizedBox(
                                              width:
                                                  AppSpacing.sm,
                                            ),
                                            itemBuilder:
                                                (
                                                  context,
                                                  index,
                                                ) {
                                                  final promotion =
                                                      businessPromotions[
                                                          index];

                                                  return PromotionCard(
                                                    // ==========================================
                                                    // CARD WIDTH
                                                    // ==========================================

                                                    width: 180,

                                                    // ==========================================
                                                    // BUSINESS
                                                    // ==========================================

                                                    businessName:
                                                        promotion
                                                            .businessName,

                                                    // ==========================================
                                                    // IMAGE
                                                    // ==========================================

                                                    coverUrl:
                                                        promotion
                                                            .photoUrl,

                                                    // ==========================================
                                                    // FOOD NAME
                                                    // ==========================================

                                                    itemName:
                                                        promotion
                                                            .itemName,

                                                    // ==========================================
                                                    // 🔥 DISCOUNT %
                                                    // ==========================================

                                                    discountPercentage:
                                                        promotion
                                                            .discountPercentage,

                                                    // ==========================================
                                                    // OLD PRICE
                                                    // ==========================================

                                                    oldPrice:
                                                        promotion
                                                            .oldPrice
                                                            ?.toDouble(),

                                                    // ==========================================
                                                    // NEW PRICE
                                                    // ==========================================

                                                    newPrice:
                                                        promotion
                                                            .newPrice
                                                            ?.toDouble(),

                                                    // ==========================================
                                                    // OPEN FOOD DETAILS
                                                    // ==========================================

                                                    onTap: () {
                                                      context.push(
                                                        '/food/${promotion.menuItemId}',
                                                      );
                                                    },
                                                  );
                                                },
                                          ),
                                        ),

                                        const SizedBox(
                                          height:
                                              AppSpacing.lg,
                                        ),
                                      ],
                                    );
                                  },
                            ),

                            // ==================================================
                            // CATEGORY CHIPS
                            // ==================================================

                            BusinessCategoryChips(
                              categoryNames:
                                  categoryNames,
                              selectedIndex:
                                  _selectedIndex,
                              onSelected: (index) {
                                setState(() {
                                  _selectedIndex =
                                      index;
                                });
                              },
                            ),

                            const SizedBox(
                              height: AppSpacing.md,
                            ),

                            // ==================================================
                            // CATEGORY TITLE
                            // ==================================================

                            Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    AppSpacing.lg,
                              ),
                              child: Text(
                                '${selectedCategory.nameAr} (${itemsInCategory.length})',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge,
                              ),
                            ),

                            const SizedBox(
                              height: AppSpacing.sm,
                            ),

                            // ==================================================
                            // FOOD GRID
                            // ==================================================

                            itemsInCategory.isEmpty
                                ? const Padding(
                                    padding:
                                        EdgeInsets.symmetric(
                                      vertical: 60,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'لا توجد أطباق في هذا القسم',
                                      ),
                                    ),
                                  )
                                : BlocBuilder<
                                    CartBloc,
                                    CartState
                                  >(
                                    builder:
                                        (
                                          context,
                                          cartState,
                                        ) {
                                          return GridView
                                              .builder(
                                            // ========================================
                                            // IMPORTANT
                                            // ========================================

                                            shrinkWrap:
                                                true,

                                            physics:
                                                const NeverScrollableScrollPhysics(),

                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal:
                                                  AppSpacing.lg,
                                              vertical:
                                                  AppSpacing.sm,
                                            ),

                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount:
                                                  2,
                                              mainAxisSpacing:
                                                  AppSpacing.sm,
                                              crossAxisSpacing:
                                                  AppSpacing.sm,
                                              childAspectRatio:
                                                  0.72,
                                            ),

                                            itemCount:
                                                itemsInCategory
                                                    .length,

                                            itemBuilder:
                                                (
                                                  context,
                                                  index,
                                                ) {
                                                  final item =
                                                      itemsInCategory[
                                                          index];

                                                  // ========================================
                                                  // CART QUANTITY
                                                  // ========================================

                                                  final matchingItemIndex =
                                                      cartState
                                                          .items
                                                          .indexWhere(
                                                    (
                                                      element,
                                                    ) =>
                                                        element
                                                            .itemId ==
                                                        item.id,
                                                  );

                                                  final itemQuantity =
                                                      matchingItemIndex !=
                                                              -1
                                                          ? cartState
                                                                .items[
                                                                    matchingItemIndex]
                                                                .quantity
                                                          : 0;

                                                  // ========================================
                                                  // FOOD CARD
                                                  // ========================================

                                                  return MenuItemGridCard(
                                                    photoUrl:
                                                        item
                                                            .photoUrl,
                                                    nameAr:
                                                        item
                                                            .nameAr,
                                                    price:
                                                        item
                                                            .price,
                                                    quantity:
                                                        itemQuantity,

                                                    // ======================================
                                                    // OPEN FOOD
                                                    // ======================================

                                                    onTap:
                                                        () =>
                                                            context.push(
                                                      '/food/${item.id}',
                                                    ),

                                                    // ======================================
                                                    // ADD
                                                    // ======================================

                                                    onAdd:
                                                        () {
                                                      context
                                                          .read<
                                                            CartBloc
                                                          >()
                                                          .add(
                                                        AddItemEvent(
                                                          item:
                                                              CartItem(
                                                            itemId:
                                                                item.id,
                                                            nameAr:
                                                                item.nameAr,
                                                            description:
                                                                item.description ??
                                                                '',
                                                            price:
                                                                item.price,
                                                            quantity:
                                                                1,
                                                            businessId:
                                                                item.businessId,
                                                          ),
                                                          businessName:
                                                              business
                                                                  .nameAr,
                                                          businessLogo:
                                                              business
                                                                  .logoUrl,
                                                        ),
                                                      );
                                                    },

                                                    // ======================================
                                                    // REMOVE
                                                    // ======================================

                                                    onRemove:
                                                        () {
                                                      context
                                                          .read<
                                                            CartBloc
                                                          >()
                                                          .add(
                                                        RemoveItemEvent(
                                                          itemId:
                                                              item.id,
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                          );
                                        },
                                  ),

                            // ==================================================
                            // BOTTOM SPACE
                            // ==================================================

                            const SizedBox(
                              height: AppSpacing.xl,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),

      // ================================================================
      // CART BAR
      // ================================================================

      bottomNavigationBar:
          BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          final hasItems =
              cartState.items.isNotEmpty;

          final totalQuantity =
              cartState.items.fold<int>(
            0,
            (sum, item) => sum + item.quantity,
          );

          return AnimatedSlide(
            duration:
                const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            offset: hasItems
                ? Offset.zero
                : const Offset(0, 1),
            child: AnimatedOpacity(
              duration:
                  const Duration(milliseconds: 200),
              opacity: hasItems ? 1.0 : 0.0,
              child: hasItems
                  ? SafeArea(
                      top: false,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          AppSpacing.lg,
                        ),
                        child: Material(
                          color:
                              AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(
                            AppRadius.md,
                          ),
                          child: InkWell(
                            onTap: () =>
                                context.go(
                              '/cart',
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              AppRadius.md,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical:
                                    AppSpacing.md,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                children: [
                                  const Icon(
                                    Icons
                                        .shopping_cart_rounded,
                                    color:
                                        Colors.white,
                                    size: 20,
                                  ),

                                  const SizedBox(
                                    width: 8,
                                  ),

                                  Text(
                                    'اذهب إلى السلة ($totalQuantity)',
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}