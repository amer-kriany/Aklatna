import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/home/presentation/widgets/home/BusinessCard.dart';
import 'package:aklatna/features/home/presentation/widgets/home/HomeDeliveryHeader.dart';
import 'package:aklatna/features/home/presentation/widgets/home/HomeGreeting.dart';
import 'package:aklatna/features/home/presentation/widgets/home/HomeSearchBar.dart';
import 'package:aklatna/features/home/presentation/widgets/home/SectionHeader.dart';
import 'package:aklatna/features/home/presentation/widgets/home/SponseredBanner.dart';
import 'package:aklatna/features/profile/domain/entities/profileEntity.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

// TODO(Amer): fix these import paths to match your real project structure
// import '../../business/presentation/bloc/business_bloc.dart';
// import '../../business/domain/entities/business_entity.dart';
// import '../../profile/presentation/bloc/profile_bloc.dart';
// import '../../../../core/routes/app_routes.dart';

/// Home page - wired to real BusinessBloc + ProfileBloc.
///
/// Profile gates the whole page (header/greeting need it) - shows a
/// full-page spinner until ProfileLoaded. Once that's ready, the
/// business sections render independently and collapse to nothing
/// (not a second spinner) until BusinessFetched arrives, since a
/// business-load delay shouldn't block the whole page from showing.
///
/// "Popular Near You" / "Recommended" aren't separate bloc states -
/// BusinessFetched only gives one flat list, so this page derives the
/// split itself: highest-rated business = Popular, the rest = Recommended.
/// TODO(Amer): confirm this is really how "popular" should be decided
/// (vs. e.g. admin-picked or a future paid placement).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Approximate - verify against real device render and adjust.
  static const double _recommendedTileWidth = 160;
  static const double _recommendedRowHeight = 210;

  @override
  void initState() {
    super.initState();
    context.read<BusinessBloc>().add(GetBusinesses());
    context.read<ProfileBloc>().add(GetProfilesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading ||
                profileState is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (profileState is ProfileError) {
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
                      "Profile not found",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(GetProfilesEvent());
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }
            final Profileentity profile;
            if (profileState is ProfileLoaded) {
              profile = profileState.profile;
            } else {
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
                      "Profile not found",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(GetProfilesEvent());
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            ///////////////////////////////////////////////////////////////////////////////////////
            return BlocBuilder<BusinessBloc, BusinessState>(
              builder: (context, businessState) {
                if (businessState is BusinessLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                if (businessState is BusinessError) {
                  return Center(child: Text(businessState.message));
                }
                List<BusinessEntity> businesses = <BusinessEntity>[];
                if (businessState is BusinessFetched) {
                  businesses = businessState.businesses;
                }

                final sorted = [...businesses]
                  ..sort((a, b) => b.rating.compareTo(a.rating));
                final popularBusiness = sorted.isNotEmpty ? sorted.first : null;
                final recommendedBusinesses = sorted.length > 1
                    ? sorted.sublist(1)
                    : <BusinessEntity>[];

                // TODO(Amer): sponsored_banners table doesn't exist yet -
                // wire this once it's built.
                const String? sponsoredBannerImageUrl =
                    "assets/images/profile.jpg";

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
                          // TODO(Amer): resolve real address source (deferred)
                          addressLabel: profile.address,
                          avatarUrl: profile.photo,
                          onAvatarTap: () {
                            context.push("/profile");
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
                        child: HomeGreeting(userName: profile.userName),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal,
                        ),
                        child: HomeSearchBar(
                          onTap: () {
                            context.go("/search");
                          },
                          onMicTap: null, // visual only, not wired in Phase 1
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      if (sponsoredBannerImageUrl != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal,
                          ),
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
                                businessId:business.id ,
                                width: _recommendedTileWidth,
                                businessName: business.nameAr,
                                coverUrl: business.coverUrl,
                                rating: business.rating,
                                ratingCount: business.ratingCount,
                                onTap: () {
                                  ///////////////////
                                  context.push("/business/${business.id}");
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      if (popularBusiness != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal,
                          ),
                          child: const SectionHeader(title: 'الأكثر طلبًا'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal,
                          ),
                          child: BusinessCard(
                            businessId:popularBusiness.id ,
                            businessName: popularBusiness.nameAr,
                            coverUrl: popularBusiness.coverUrl,
                            rating: popularBusiness.rating,
                            ratingCount: popularBusiness.ratingCount,
                            onTap: () {
                              ////////////////////
                              context.push("/business/${popularBusiness.id}");
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
