import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/home/presentation/widgets/BusinessCard.dart';
import 'package:aklatna/features/home/presentation/widgets/HomeDeliveryHeader.dart';
import 'package:aklatna/features/home/presentation/widgets/HomeGreeting.dart';
import 'package:aklatna/features/home/presentation/widgets/HomeSearchBar.dart';
import 'package:aklatna/features/home/presentation/widgets/SectionHeader.dart';
import 'package:aklatna/features/home/presentation/widgets/SponseredBanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';


// TODO(Amer): import your real Bloc/state/entity classes:
// import '../bloc/home_bloc.dart';
// import '../bloc/home_state.dart';
// import '../../domain/entities/business_entity.dart';
// import '../../../../core/routes/app_routes.dart';

/// Home page - wired directly to HomeBloc.
///
/// TODO(Amer): replace `HomeBloc`/`HomeState` below with your real classes.
/// If HomeState is a sealed hierarchy (HomeInitial/HomeLoading/HomeLoaded/
/// HomeError) rather than one flat class, restructure the builder below
/// to switch on `state is HomeLoaded` etc. instead of reading fields
/// directly off `state`.
///
/// Every section (popular/recommended/banner) collapses to nothing if its
/// data is null/empty - no placeholder content is ever shown.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Approximate - verify against real device render and adjust.
  static const double _recommendedTileWidth = 160;
  static const double _recommendedRowHeight = 210;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<BusinessBloc, BusinessState>(
          builder: (context, state) {
            // TODO(Amer): loading state
            // if (state is HomeLoading) {
            //   return const Center(child: CircularProgressIndicator());
            // }

            // TODO(Amer): error state
            // if (state is HomeError) {
            //   return Center(child: Text(state.message));
            // }

            // TODO(Amer): pull these from your real loaded state fields
            final String addressLabel = "alhamraa street";
            final String? avatarUrl = null;
            final String userName = "AmerKriany";
            final BusinessEntity? popularBusiness = null;
            final List<BusinessEntity> recommendedBusinesses = [];
            final String? sponsoredBannerImageUrl =
                null;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: HomeDeliveryHeader(
                      addressLabel: addressLabel,
                      avatarUrl: avatarUrl,
                      onAvatarTap: () {
                        // TODO(Amer): context.push(AppRoutes.profile);
                      },
                      onAddressTap: () {
                        // TODO(Amer): context.push(AppRoutes.addressSelect);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: HomeGreeting(userName: userName),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: HomeSearchBar(
                      onTap: () {
                        // TODO(Amer): context.push(AppRoutes.search);
                      },
                      onMicTap: null, // visual only, not wired in Phase 1
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  if (popularBusiness != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal,
                      ),
                      child: const SectionHeader(title: 'الأكثر طلبًا'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal,
                      ),
                      child: BusinessCard(
                        businessName: popularBusiness.nameAr,
                        coverUrl: popularBusiness.coverUrl,
                        rating: popularBusiness.rating,
                        ratingCount: popularBusiness.ratingCount,
                        onTap: () {
                          // TODO(Amer): context.push('${AppRoutes.business}/${popularBusiness.id}');
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  if (recommendedBusinesses.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal,
                      ),
                      child: const SectionHeader(title: 'موصى لك'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: _recommendedRowHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(
                          left: AppSpacing.pageHorizontal,
                          right: AppSpacing.sm,
                        ),
                        itemCount: recommendedBusinesses.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final business = recommendedBusinesses[index];
                          return BusinessCard(
                            width: _recommendedTileWidth,
                            businessName: business.nameAr,
                            coverUrl: business.coverUrl,
                            rating: business.rating,
                            ratingCount: business.ratingCount,
                            onTap: () {
                              // TODO(Amer): context.push('${AppRoutes.business}/${business.id}');
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  if (sponsoredBannerImageUrl != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal,
                      ),
                      child: const SectionHeader(title: 'إعلانات'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal,
                      ),
                      child: SponsoredBanner(
                        imageUrl: sponsoredBannerImageUrl,
                        onTap: () {
                          // TODO(Amer): decide destination once sponsored_banners table exists
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
