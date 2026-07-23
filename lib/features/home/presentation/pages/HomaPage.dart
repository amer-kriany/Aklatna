import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/home/presentation/widgets/home/BusinessCard.dart';
import 'package:aklatna/features/home/presentation/widgets/home/HomeDeliveryHeader.dart';
import 'package:aklatna/features/home/presentation/widgets/home/HomeGreeting.dart';
import 'package:aklatna/features/home/presentation/widgets/home/HomeSearchBar.dart';
import 'package:aklatna/features/home/presentation/widgets/home/SectionHeader.dart';
import 'package:aklatna/features/home/presentation/widgets/home/SponseredBanner.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _recommendedTileWidth = 160;
  static const double _recommendedRowHeight = 210;

  @override
  void initState() {
    super.initState();
    context.read<BusinessBloc>().add(GetBusinesses());
    context.read<ProfileBloc>().add(GetProfilesEvent());
  }

  /// Extracts only Street and City from full address string
  String _formatAddress(String? fullAddress) {
    if (fullAddress == null || fullAddress.trim().isEmpty) return '';
    final parts = fullAddress.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (parts.length >= 2) {
      // Returns "Street, City" (taking first and last non-empty parts)
      return '${parts.first}, ${parts.last}';
    }
    return fullAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading || profileState is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (profileState is ProfileError || profileState is! ProfileLoaded) {
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

            final profile = profileState.profile;

            return BlocBuilder<BusinessBloc, BusinessState>(
              builder: (context, businessState) {
                if (businessState is BusinessLoading) {
                  return const Center(child: CircularProgressIndicator());
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
                final recommendedBusinesses =
                    sorted.length > 1 ? sorted.sublist(1) : <BusinessEntity>[];

                const String? sponsoredBannerImageUrl = "assets/images/profile.jpg";

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
                          // Formatted to display only Street, City
                          addressLabel: _formatAddress(profile.address),
                          avatarUrl: profile.photo,
                          onAvatarTap: () async {
                            // Re-fetches profile data when returning from Profile page
                            await context.push("/profile");
                            if (context.mounted) {
                              context.read<ProfileBloc>().add(GetProfilesEvent());
                            }
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
                          onMicTap: null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      if (sponsoredBannerImageUrl != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal,
                          ),
                          child: SponsoredBanner(
                            imageUrl: sponsoredBannerImageUrl,
                            onTap: () {},
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
                                businessId: business.id,
                                width: _recommendedTileWidth,
                                businessName: business.nameAr,
                                coverUrl: business.coverUrl,
                                rating: business.rating,
                                ratingCount: business.ratingCount,
                                onTap: () {
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal,
                          ),
                          child: BusinessCard(
                            businessId: popularBusiness.id,
                            businessName: popularBusiness.nameAr,
                            coverUrl: popularBusiness.coverUrl,
                            rating: popularBusiness.rating,
                            ratingCount: popularBusiness.ratingCount,
                            onTap: () {
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