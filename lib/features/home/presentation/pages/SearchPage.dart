import 'dart:async';

import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/home/presentation/widgets/search/popularDishes.dart';
import 'package:aklatna/features/home/presentation/widgets/search/recentKeyword.dart';
import 'package:aklatna/features/home/presentation/widgets/search/searchBarState.dart'
    as app;
import 'package:aklatna/features/home/presentation/widgets/search/searchResultCard.dart';
import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:aklatna/features/menu/domain/entity/menuItemEntity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  List<String> _recentKeywords = [];
  String _query = '';
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
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    // Recent keywords logic if needed
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (value.trim().isEmpty) return;
      context.read<BusinessBloc>().add(SearchBusinesses(query: value.trim()));
    });
  }

  void _onRecentKeywordTap(String keyword) {
    _controller.text = keyword;
    setState(() => _query = keyword);
    if (keyword.trim().isEmpty) return;
    context.read<BusinessBloc>().add(SearchBusinesses(query: keyword.trim()));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
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
              
              // Top Bar: Page Title + Favorites Heart Icon
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
              app.SearchBar(
                controller: _controller,
                onQueryChanged: _onQueryChanged,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView(
                  children: [
                    if (_query.trim().isEmpty &&
                        _recentKeywords.isNotEmpty) ...[
                      RecentKeywords(
                        keywords: _recentKeywords,
                        onTap: _onRecentKeywordTap,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (_query.trim().isNotEmpty) _buildResults(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildIdleContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Popular dishes slider at the bottom
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
                height: 210,
                child: Center(child: CircularProgressIndicator()),
              ),
            if (state is MenuError)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(state.message, style: AppTextStyles.bodyMedium),
              ),
            if (state is! MenuLoading && popularItems.isNotEmpty) ...[
              SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularItems.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = popularItems[index];
                    return PopularDishCard(
                      onTap: () => context.push("/food/${item.id}"),
                      photoUrl: item.photoUrl ?? '',
                      dishNameAr: item.nameAr,
                      dishPrice: item.price,
                      businessNameAr: businessNamesById[item.businessId] ?? '',
                    );
                  },
                ),
              ),
            ],
            if (state is! MenuLoading && popularItems.isEmpty)
              const SizedBox(
                height: 210,
                child: Center(child: Text('لا توجد أطباق حالياً')),
              ),
          ],
        );
      },
    );
  }

  /// Active query search results
  Widget _buildResults() {
    return BlocBuilder<BusinessBloc, BusinessState>(
      builder: (context, state) {
        if (state is BusinessLoading) {
          return const Center(child: CircularProgressIndicator());
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