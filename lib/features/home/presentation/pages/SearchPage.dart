import 'dart:async';

import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_state.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/home/presentation/widgets/businesses/MenuItemGridCard.dart';
import 'package:aklatna/features/home/presentation/widgets/search/popularDishes.dart';
import 'package:aklatna/features/home/presentation/widgets/search/searchBarState.dart'
    as app;
import 'package:aklatna/features/home/presentation/widgets/search/searchResultCard.dart';
import 'package:aklatna/features/menu/domain/entity/menuItemEntity.dart';
import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/page_skeletons.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  String _query = '';
  String? _selectedCategoryName;

  Timer? _debounce;

  late final AnimationController _introController;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    if (context.read<MenuBloc>().state is MenuInitial) {
      context.read<MenuBloc>().add(
            const GetAllMenu(),
          );
    }

    if (context.read<BusinessBloc>().state is BusinessInitial) {
      context.read<BusinessBloc>().add(
            GetBusinesses(),
          );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _introController.forward();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _introController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // SEARCH
  // ===========================================================================

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
    });

    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 350),
      () {
        if (!mounted) return;

        final query = value.trim();

        if (query.isEmpty) {
          return;
        }

        context.read<BusinessBloc>().add(
              SearchBusinesses(
                query: query,
              ),
            );
      },
    );
  }

  // ===========================================================================
  // CART
  // ===========================================================================

  int _getCartQuantity(
    CartState cartState,
    String itemId,
  ) {
    final matchingItems = cartState.items.where(
      (item) => item.itemId == itemId,
    );

    if (matchingItems.isEmpty) {
      return 0;
    }

    return matchingItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  void _addItemToCart(
    BuildContext context,
    Menuitementity item,
  ) {
    final businessState =
        context.read<BusinessBloc>().state;

    String? businessName;
    String? businessLogo;

    if (businessState is BusinessFetched) {
      for (final business in businessState.businesses) {
        if (business.id == item.businessId) {
          businessName = business.nameAr;
          businessLogo = business.logoUrl;
          break;
        }
      }
    }

    context.read<CartBloc>().add(
          AddItemEvent(
            item: CartItem(
              itemId: item.id,
              nameAr: item.nameAr,
              description: item.description ?? '',
              photoUrl: item.photoUrl,
              price: item.price,
              quantity: 1,
              businessId: item.businessId,
              note: '',
              selectedAddons: [],
            ),
            businessName: businessName,
            businessLogo: businessLogo,
          ),
        );
  }

  void _removeItemFromCart(
    BuildContext context,
    String itemId,
  ) {
    context.read<CartBloc>().add(
          RemoveItemEvent(
            itemId: itemId,
          ),
        );
  }

  // ===========================================================================
  // INTRO ANIMATION
  // ===========================================================================

  Widget _animatedIntro({
    required Widget child,
    double begin = 16,
  }) {
    return AnimatedBuilder(
      animation: _introController,
      child: child,
      builder: (context, child) {
        final value = Curves.easeOutCubic.transform(
          _introController.value,
        );

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              begin * (1 - value),
            ),
            child: child,
          ),
        );
      },
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: AppSpacing.md,
              ),

              // =================================================================
              // HEADER
              // =================================================================

              _animatedIntro(
                begin: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'البحث',
                        style: AppTextStyles.h2,
                      ),
                    ),

                    // Favorites
                    Material(
                      color: AppColors.surface,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          context.push('/favorites');
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.favorite_border_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              // =================================================================
              // SEARCH BAR
              // =================================================================

              _animatedIntro(
                begin: 14,
                child: app.SearchBar(
                  controller: _controller,
                  onQueryChanged: _onQueryChanged,
                ),
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              // =================================================================
              // CONTENT
              // =================================================================

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 220,
                  ),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: ListView(
                    key: ValueKey(
                      _query.trim().isEmpty
                          ? 'idle'
                          : 'search',
                    ),
                    physics:
                        const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.xl,
                    ),
                    children: [
                      if (_query.trim().isEmpty) ...[
                        _buildCategoryChipsAndResults(),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        _buildIdleContent(),
                      ],

                      if (_query.trim().isNotEmpty)
                        _buildResults(),
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

  // ===========================================================================
  // CATEGORIES
  // ===========================================================================

  Widget _buildCategoryChipsAndResults() {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        if (state is! MenuAllLoaded) {
          return const SizedBox.shrink();
        }

        final categoryNames = state.categories
            .map((category) => category.nameAr)
            .toSet()
            .toList();

        if (categoryNames.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'تصفح حسب القسم',
                    style: AppTextStyles.h4,
                  ),
                ),
                if (_selectedCategoryName != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategoryName = null;
                      });
                    },
                    child: Text(
                      'إلغاء',
                      style:
                          AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            // ================================================================
            // CATEGORY CHIPS
            // ================================================================

            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics:
                    const BouncingScrollPhysics(),
                itemCount: categoryNames.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(
                  width: AppSpacing.sm,
                ),
                itemBuilder: (context, index) {
                  final name = categoryNames[index];

                  final isSelected =
                      _selectedCategoryName == name;

                  return AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 180,
                    ),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(
                        AppRadius.full,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(
                          AppRadius.full,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedCategoryName =
                                isSelected
                                    ? null
                                    : name;
                          });
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.xs,
                          ),
                          child: Center(
                            child: Text(
                              name,
                              style: AppTextStyles
                                  .bodyMedium
                                  .copyWith(
                                color: isSelected
                                    ? AppColors
                                        .textOnPrimary
                                    : AppColors
                                        .textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ================================================================
            // CATEGORY RESULTS
            // ================================================================

            AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 220,
              ),
              child: _selectedCategoryName == null
                  ? const SizedBox.shrink()
                  : Padding(
                      key: ValueKey(
                        _selectedCategoryName,
                      ),
                      padding:
                          const EdgeInsets.only(
                        top: AppSpacing.lg,
                      ),
                      child: _buildCategoryResults(
                        state,
                        _selectedCategoryName!,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // CATEGORY RESULTS
  // ===========================================================================

  Widget _buildCategoryResults(
    MenuAllLoaded state,
    String categoryName,
  ) {
    final categoryIds = state.categories
        .where(
          (category) =>
              category.nameAr == categoryName,
        )
        .map(
          (category) => category.id,
        )
        .toSet();

    final matchingItems = state.items
        .where(
          (item) =>
              categoryIds.contains(item.categoryId),
        )
        .toList();

    if (matchingItems.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(
          AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 34,
              color: AppColors.textSecondary,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              'لا توجد أطباق في هذا القسم حالياً',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final businessState =
        context.watch<BusinessBloc>().state;

    final Map<String, String> businessNamesById =
        businessState is BusinessFetched
            ? {
                for (final business
                    in businessState.businesses)
                  business.id: business.nameAr,
              }
            : const {};

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width >= 700 ? 3 : 2;

        final rows = <Widget>[];

        for (
          int index = 0;
          index < matchingItems.length;
          index += columns
        ) {
          final rowItems = matchingItems
              .skip(index)
              .take(columns)
              .toList();

          final rowChildren = <Widget>[];

          for (
            int column = 0;
            column < columns;
            column++
          ) {
            if (column < rowItems.length) {
              final item = rowItems[column];

              rowChildren.add(
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: column == 0
                          ? 0
                          : AppSpacing.xs,
                      right: column == columns - 1
                          ? 0
                          : AppSpacing.xs,
                      bottom: AppSpacing.md,
                    ),
                    child: BlocBuilder<CartBloc, CartState>(
                      buildWhen: (previous, current) {
                        return _getCartQuantity(
                              previous,
                              item.id,
                            ) !=
                            _getCartQuantity(
                              current,
                              item.id,
                            );
                      },
                      builder: (
                        context,
                        cartState,
                      ) {
                        final quantity =
                            _getCartQuantity(
                          cartState,
                          item.id,
                        );

                        return MenuItemGridCard(
                          photoUrl: item.photoUrl,
                          nameAr: item.nameAr,
                          price: item.price,
                          businessNameAr:
                              businessNamesById[
                                  item.businessId],
                          quantity: quantity,
                          onAdd: () {
                            _addItemToCart(
                              context,
                              item,
                            );
                          },
                          onRemove: () {
                            _removeItemFromCart(
                              context,
                              item.id,
                            );
                          },
                          onTap: () {
                            context.push(
                              '/food/${item.id}',
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            } else {
              rowChildren.add(
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
              children: rowChildren,
            ),
          );
        }

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }

  // ===========================================================================
  // IDLE CONTENT
  // ===========================================================================

  Widget _buildIdleContent() {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        final List<Menuitementity> menuItems =
            state is MenuAllLoaded
                ? state.items
                : const <Menuitementity>[];

        final businessState =
            context.watch<BusinessBloc>().state;

        final Map<String, double>
            businessRatingsById =
            businessState is BusinessFetched
                ? {
                    for (final business
                        in businessState.businesses)
                      business.id: business.rating,
                  }
                : const {};

        final Map<String, String>
            businessNamesById =
            businessState is BusinessFetched
                ? {
                    for (final business
                        in businessState.businesses)
                      business.id: business.nameAr,
                  }
                : const {};

        final rankedItems = [...menuItems];

        rankedItems.sort(
          (a, b) {
            final ratingA =
                businessRatingsById[a.businessId] ?? 0;

            final ratingB =
                businessRatingsById[b.businessId] ?? 0;

            final ratingComparison =
                ratingB.compareTo(ratingA);

            if (ratingComparison != 0) {
              return ratingComparison;
            }

            return a.sortOrder.compareTo(
              b.sortOrder,
            );
          },
        );

        final popularItems =
            rankedItems.take(10).toList();

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'أطباق شائعة',
                    style: AppTextStyles.h4,
                  ),
                ),
                if (popularItems.isNotEmpty)
                  Text(
                    'الأكثر طلباً',
                    style:
                        AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            if (state is MenuLoading)
              const SizedBox(
                height: 180,
                child: ListSkeleton(
                  itemCount: 3,
                  showLeadingCircle: false,
                ),
              ),

            if (state is MenuError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.lg,
                  ),
                ),
                child: Text(
                  state.message,
                  style:
                      AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            if (state is! MenuLoading &&
                popularItems.isNotEmpty)
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection:
                      Axis.horizontal,
                  physics:
                      const BouncingScrollPhysics(),
                  itemCount:
                      popularItems.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(
                    width: AppSpacing.sm,
                  ),
                  itemBuilder: (context, index) {
                    final item =
                        popularItems[index];

                    return BlocBuilder<CartBloc,
                        CartState>(
                      buildWhen: (previous, current) {
                        return _getCartQuantity(
                              previous,
                              item.id,
                            ) !=
                            _getCartQuantity(
                              current,
                              item.id,
                            );
                      },
                      builder: (
                        context,
                        cartState,
                      ) {
                        final quantity =
                            _getCartQuantity(
                          cartState,
                          item.id,
                        );

                        return PopularDishCard(
                          photoUrl:
                              item.photoUrl ?? '',
                          dishNameAr:
                              item.nameAr,
                          dishPrice:
                              item.price,
                          businessNameAr:
                              businessNamesById[
                                      item.businessId] ??
                                  '',
                          quantity:
                              quantity,
                          onAdd: () {
                            _addItemToCart(
                              context,
                              item,
                            );
                          },
                          onRemove: () {
                            _removeItemFromCart(
                              context,
                              item.id,
                            );
                          },
                          onTap: () {
                            context.push(
                              '/food/${item.id}',
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

            if (state is! MenuLoading &&
                popularItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_menu_outlined,
                      size: 42,
                      color:
                          AppColors.textSecondary,
                    ),
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),
                    Text(
                      'لا توجد أطباق حالياً',
                      style:
                          AppTextStyles.bodyMedium.copyWith(
                        color:
                            AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // SEARCH RESULTS
  // ===========================================================================

  Widget _buildResults() {
    return BlocBuilder<BusinessBloc, BusinessState>(
      builder: (context, state) {
        if (state is BusinessLoading) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'نتائج البحث',
                style: AppTextStyles.h4,
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              const SizedBox(
                height: 220,
                child: ListSkeleton(
                  itemCount: 4,
                ),
              ),
            ],
          );
        }

        if (state is BusinessUnfound) {
          return _buildEmptySearchState();
        }

        if (state is BusinessError) {
          return _buildSearchErrorState(
            state.message,
          );
        }

        if (state is BusinessFetched) {
          if (state.businesses.isEmpty) {
            return _buildEmptySearchState();
          }

          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'نتائج البحث',
                      style: AppTextStyles.h4,
                    ),
                  ),
                  Text(
                    '${state.businesses.length} نتيجة',
                    style:
                        AppTextStyles.bodySmall.copyWith(
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              ListView.separated(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount:
                    state.businesses.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(
                    height: AppSpacing.xs,
                  );
                },
                itemBuilder: (
                  context,
                  index,
                ) {
                  final business =
                      state.businesses[index];

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(
                        AppRadius.lg,
                      ),
                      onTap: () {
                        context.push(
                          '/business/${business.id}',
                        );
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical:
                              AppSpacing.xs,
                        ),
                        child: SearchResultCard(
                          business: business,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ===========================================================================
  // EMPTY SEARCH
  // ===========================================================================

  Widget _buildEmptySearchState() {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xl,
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 32,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            Text(
              'ما لقينا نتائج',
              style: AppTextStyles.h4,
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            Text(
              'جرّب البحث باسم مطعم أو نوع أكلة مختلف',
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SEARCH ERROR
  // ===========================================================================

  Widget _buildSearchErrorState(
    String message,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(
          AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(
            AppRadius.lg,
          ),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 36,
              color: AppColors.textSecondary,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              'حدث خطأ أثناء البحث',
              style: AppTextStyles.h4,
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
