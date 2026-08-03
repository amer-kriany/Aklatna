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

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();

  String _query = '';
  String? _selectedCategoryName;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    if (context.read<MenuBloc>().state is MenuInitial) {
      context.read<MenuBloc>().add(const GetAllMenu());
    }

    if (context.read<BusinessBloc>().state is BusinessInitial) {
      context.read<BusinessBloc>().add(GetBusinesses());
    }
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (value.trim().isEmpty) return;

      context.read<BusinessBloc>().add(SearchBusinesses(query: value.trim()));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // GET ITEM QUANTITY FROM CART
  // ============================================================

  int _getCartQuantity(CartState cartState, String itemId) {
    final item = cartState.items.where((item) => item.itemId == itemId);

    if (item.isEmpty) return 0;

    return item.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  // ============================================================
  // ADD ITEM TO CART
  // ============================================================

  void _addItemToCart(BuildContext context, Menuitementity item) {
    final businessState = context.read<BusinessBloc>().state;

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

  // ============================================================
  // REMOVE ITEM FROM CART
  // ============================================================

  void _removeItemFromCart(BuildContext context, String itemId) {
    context.read<CartBloc>().add(RemoveItemEvent(itemId: itemId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),

              // ==================================================
              // HEADER
              // ==================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('البحث', style: AppTextStyles.h2),
                  IconButton(
                    onPressed: () => context.push('/favorites'),
                    icon: const Icon(
                      Icons.favorite_border,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    tooltip: 'المطاعم المفضلة',
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // ==================================================
              // SEARCH BAR
              // ==================================================
              app.SearchBar(
                controller: _controller,
                onQueryChanged: _onQueryChanged,
              ),

              const SizedBox(height: AppSpacing.lg),

              // ==================================================
              // CONTENT
              // ==================================================
              Expanded(
                child: ListView(
                  children: [
                    if (_query.trim().isEmpty) _buildCategoryChipsAndResults(),
                    if (_query.trim().isNotEmpty) _buildResults(),
                    const SizedBox(height: AppSpacing.lg),
                    if (_query.trim().isEmpty) _buildIdleContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY CHIPS
  // ============================================================

  Widget _buildCategoryChipsAndResults() {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        if (state is! MenuAllLoaded) {
          return const SizedBox.shrink();
        }

        final distinctCategoryNames = state.categories
            .map((c) => c.nameAr)
            .toSet()
            .toList();

        if (distinctCategoryNames.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: distinctCategoryNames.map((name) {
                    final isSelected = _selectedCategoryName == name;

                    return Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryName = isSelected ? null : name;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isSelected
                                  ? AppColors.textOnPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_selectedCategoryName != null) ...[
                const SizedBox(height: AppSpacing.md),
                _buildCategoryResults(state, _selectedCategoryName!),
              ],
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // CATEGORY RESULTS
  // ============================================================

  Widget _buildCategoryResults(MenuAllLoaded state, String categoryName) {
    final matchingCategoryIds = state.categories
        .where((c) => c.nameAr == categoryName)
        .map((c) => c.id)
        .toSet();

    final matchingItems = state.items
        .where((i) => matchingCategoryIds.contains(i.categoryId))
        .toList();

    if (matchingItems.isEmpty) {
      return Text(
        'لا توجد أطباق في هذا القسم',
        style: AppTextStyles.bodyMedium,
      );
    }

    final businessState = context.watch<BusinessBloc>().state;

    final Map<String, String> businessNamesById =
        businessState is BusinessFetched
        ? {
            for (final business in businessState.businesses)
              business.id: business.nameAr,
          }
        : const <String, String>{};

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.75,
      ),
      itemCount: matchingItems.length,
      itemBuilder: (context, index) {
        final item = matchingItems[index];

        return MenuItemGridCard(
          photoUrl: item.photoUrl,
          nameAr: item.nameAr,
          price: item.price,
          businessNameAr: businessNamesById[item.businessId],
          onTap: () => context.push('/food/${item.id}'),
        );
      },
    );
  }

  // ============================================================
  // IDLE CONTENT / POPULAR DISHES
  // ============================================================

  Widget _buildIdleContent() {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        final List<Menuitementity> menuItems = state is MenuAllLoaded
            ? state.items
            : const <Menuitementity>[];

        final businessState = context.watch<BusinessBloc>().state;

        final Map<String, double> businessRatingsById =
            businessState is BusinessFetched
            ? {
                for (final business in businessState.businesses)
                  business.id: business.rating,
              }
            : const <String, double>{};

        final Map<String, String> businessNamesById =
            businessState is BusinessFetched
            ? {
                for (final business in businessState.businesses)
                  business.id: business.nameAr,
              }
            : const <String, String>{};

        final rankedItems = [...menuItems]
          ..sort((a, b) {
            final ratingA = businessRatingsById[a.businessId] ?? 0;
            final ratingB = businessRatingsById[b.businessId] ?? 0;

            final byRating = ratingB.compareTo(ratingA);
            if (byRating != 0) return byRating;

            return a.sortOrder.compareTo(b.sortOrder);
          });

        final popularItems = rankedItems.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('أطباق شائعة', style: AppTextStyles.h4),
            const SizedBox(height: AppSpacing.md),
            if (state is MenuLoading)
              const SizedBox(
                height: 180,
                child: ListSkeleton(itemCount: 3, showLeadingCircle: false),
              ),
            if (state is MenuError)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(state.message, style: AppTextStyles.bodyMedium),
              ),
            if (state is! MenuLoading && popularItems.isNotEmpty)
              // Dynamically fits popular card items using IntrinsicHeight
              IntrinsicHeight(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: popularItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: BlocBuilder<CartBloc, CartState>(
                          builder: (context, cartState) {
                            final quantity = _getCartQuantity(
                              cartState,
                              item.id,
                            );

                            return PopularDishCard(
                              photoUrl: item.photoUrl ?? '',
                              dishNameAr: item.nameAr,
                              dishPrice: item.price,
                              businessNameAr:
                                  businessNamesById[item.businessId] ?? '',
                              quantity: quantity,
                              onAdd: () => _addItemToCart(context, item),
                              onRemove: () =>
                                  _removeItemFromCart(context, item.id),
                              onTap: () => context.push('/food/${item.id}'),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            if (state is! MenuLoading && popularItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(child: Text('لا توجد أطباق حالياً')),
              ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUSINESS SEARCH RESULTS
  // ============================================================

  Widget _buildResults() {
    return BlocBuilder<BusinessBloc, BusinessState>(
      builder: (context, state) {
        if (state is BusinessLoading) {
          return const SizedBox(height: 220, child: ListSkeleton(itemCount: 4));
        }

        if (state is BusinessUnfound) {
          return Center(
            child: Text('ما لقينا نتائج', style: AppTextStyles.bodyMedium),
          );
        }

        if (state is BusinessError) {
          return Center(
            child: Text(state.message, style: AppTextStyles.bodyMedium),
          );
        }

        if (state is BusinessFetched) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.businesses.length,
            separatorBuilder: (_, __) =>
                const Divider(color: AppColors.divider),
            itemBuilder: (context, index) {
              final business = state.businesses[index];

              return GestureDetector(
                onTap: () {
                  context.push("/business/${business.id}");
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: SearchResultCard(business: business),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
