import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/home/presentation/widgets/businessTypeFilter.dart';
import 'package:aklatna/features/home/presentation/widgets/homeHeader.dart';
import 'package:aklatna/features/home/presentation/widgets/homeSearchBar.dart';
import 'package:aklatna/features/home/presentation/widgets/openNowSection.dart';
import 'package:aklatna/features/home/presentation/widgets/promotionsSections.dart';
import 'package:aklatna/features/home/presentation/widgets/trendingSection.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';


/// Home page — combines all Home widgets.
///
/// ⚠️ NO BLOC CONNECTED — per your rule. All three sections are passed
/// empty lists below, so they render collapsed (SizedBox.shrink) until
/// you wire real data in. Local State is only used for the type filter.
/// Wire it yourself:
///   - Wrap this in a BlocBuilder<HomeBloc, HomeState>
///   - Replace the empty `const []` below with state.trending / state.promotions / state.openNow
///     (map your real BusinessEntity/Promotion entities to TrendingCardData /
///     PromotionCardData — see the TODOs in each section file)
///   - Replace _selectedFilter local state with a Bloc event if you want
///     the filter to trigger a new fetch, or keep it local if it's
///     purely a client-side filter over already-fetched businesses
///   - Wire onCardTap / onBannerTap to context.push(AppRoutes.businessDetailPath(id))
///   - Wire HomeSearchBar's onTap to navigate to a Search screen (if you add one)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BusinessTypeFilterOption _selectedFilter = BusinessTypeFilterOption.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          // TODO: wire to HomeBloc's refresh event
          onRefresh: () async {},
          child: ListView(
            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xxl),
            children: [
              const HomeHeader(),
              const SizedBox(height: AppSpacing.md),
              HomeSearchBar(
                onTap: () {
                  // TODO: navigate to Search screen if you add one
                },
              ),
           
              const SizedBox(height: AppSpacing.lg),
              TrendingSection(
                items: const <TrendingCardData>[], // TODO: state.trending from HomeBloc
                onSeeAll: () {
                  // TODO: navigate to a full Trending list screen
                },
                onCardTap: (businessId) {
                  // TODO: context.push(AppRoutes.businessDetailPath(businessId));
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              PromotionsSection(
                items: const <PromotionCardData>[], // TODO: state.promotions from HomeBloc
                onSeeAll: () {
                  // TODO: navigate to a full Promotions list screen
                },
                onBannerTap: (businessId) {
                  // TODO: context.push(AppRoutes.businessDetailPath(businessId));
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              OpenNowSection(
                items: const <TrendingCardData>[], // TODO: state.openNow from HomeBloc
                onSeeAll: () {
                  // TODO: navigate to a full Open Now list screen
                },
                onCardTap: (businessId) {
                  // TODO: context.push(AppRoutes.businessDetailPath(businessId));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}