import 'dart:async';

import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/theme/app_colors.dart';

import 'package:aklatna/features/addresses/presentation/bloc/address_bloc.dart';
import 'package:aklatna/features/favorit/presentation/bloc/favorite_bloc.dart';
import 'package:aklatna/features/home/presentation/pages/PeriodicRebuildMixin.dart';

import 'package:aklatna/features/home/presentation/widgets/home/AddressSelectionBottomSheet.dart';
import 'package:aklatna/features/home/presentation/widgets/home/BusinessCard.dart';
import 'package:aklatna/features/home/presentation/widgets/home/HomeDeliveryHeader.dart';
import 'package:aklatna/features/home/presentation/widgets/home/HomeGreeting.dart';
import 'package:aklatna/features/home/presentation/widgets/home/HomeSearchBar.dart';
import 'package:aklatna/features/home/presentation/widgets/home/ProfileTooltipOverlay.dart';
import 'package:aklatna/features/home/presentation/widgets/home/SectionHeader.dart';
import 'package:aklatna/features/home/presentation/widgets/home/SponseredBanner.dart';
import 'package:aklatna/features/home/presentation/widgets/home/ongoingOrderCard.dart.dart';
import 'package:aklatna/features/orders/orderStatus.dart';

import 'package:aklatna/features/orders/presentation/pages/orderDetailsPage.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';

import 'package:aklatna/features/promotions/presentaion/bloc/promotions_bloc.dart';
import 'package:aklatna/features/promotions/presentaion/widgets/promotionCard.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/page_skeletons.dart';

import '../../business_type.dart';
import '../../domain/entity/businessEntity.dart';
import '../bloc/business_bloc.dart';

import '../../../profile/presentaion/bloc/profile_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, PeriodicRebuildMixin {
  static const double _recommendedTileWidth = 160;
  static const double _recommendedRowHeight = 220;

  final LayerLink _profileLayerLink = LayerLink();

  late final AnimationController _profilePulseController;

  OverlayEntry? _profileTooltipEntry;
  Timer? _profileTooltipTimer;

  @override
  void initState() {
    super.initState();

    context.read<BusinessBloc>().add(
      GetBusinesses(),
    );

    context.read<PromotionsBloc>().add(
      LoadPromotionsEvent(),
    );

    startPeriodicRebuild();

    _profilePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      lowerBound: 1.0,
      upperBound: 1.08,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showProfileHint();
    });
  }

  @override
  void dispose() {
    stopPeriodicRebuild();

    _profileTooltipTimer?.cancel();

    _profileTooltipEntry?.remove();
    _profileTooltipEntry = null;

    _profilePulseController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // PROFILE HINT
  // ===========================================================================

  void _showProfileHint() {
    if (!mounted) return;

    _hideProfileHint();

    _profileTooltipEntry = OverlayEntry(
      builder: (context) {
        return IgnorePointer(
          child: CompositedTransformFollower(
            link: _profileLayerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 6),
            child: const Material(
              color: Colors.transparent,
              child: ProfileTooltipOverlay(),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(
      _profileTooltipEntry!,
    );

    _profilePulseController.repeat(
      reverse: true,
      period: const Duration(milliseconds: 450),
    );

    Future.delayed(
      const Duration(milliseconds: 1800),
      () {
        if (!mounted) return;

        _profilePulseController.stop();
        _profilePulseController.value = 1.0;
      },
    );

    _profileTooltipTimer?.cancel();

    _profileTooltipTimer = Timer(
      const Duration(seconds: 6),
      _hideProfileHint,
    );
  }

  void _hideProfileHint() {
    _profileTooltipTimer?.cancel();
    _profileTooltipTimer = null;

    _profileTooltipEntry?.remove();
    _profileTooltipEntry = null;

    if (mounted) {
      _profilePulseController.stop();
      _profilePulseController.value = 1.0;
    }
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  String _formatAddress(String? fullAddress) {
    if (fullAddress == null || fullAddress.trim().isEmpty) {
      return '';
    }

    final parts = fullAddress
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      return '${parts.first}, ${parts.last}';
    }

    return fullAddress;
  }

  String _typeLabel(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return 'مطعم';

      case BusinessType.juice_shop:
        return 'محل عصائر';
    }
  }

  // ===========================================================================
  // ADDRESS
  // ===========================================================================

  Future<void> _showAddressBottomSheet(
    BuildContext context,
    String userId,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (_) {
        return AddressSelectionBottomSheet(
          userId: userId,
        );
      },
    );

    if (!mounted) return;

    context.read<ProfileBloc>().add(
      GetProfilesEvent(),
    );
  }

  // ===========================================================================
  // SECTION SPACING
  // ===========================================================================

  Widget _sectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      child: Container(
        height: 1,
        color: AppColors.divider.withOpacity(0.65),
      ),
    );
  }

  Widget _sectionTopSpace() {
    return const SizedBox(
      height: AppSpacing.xl,
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
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (
            context,
            profileState,
          ) {
            if (profileState is ProfileLoading ||
                profileState is ProfileInitial) {
              return const DashboardSkeleton();
            }

            if (profileState is ProfileError ||
                profileState is! ProfileLoaded) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Profile not found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(
                          GetProfilesEvent(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final profile = profileState.profile;

            final orderBloc = context.read<OrderBloc>();

            if (orderBloc.state is OrderInitial) {
              orderBloc.add(
                GetCustomerOrdersEvent(
                  customerId: profile.id,
                ),
              );
            }

            final addressBloc = context.read<AddressBloc>();

            if (addressBloc.state is AddressInitial) {
              addressBloc.add(
                LoadAddressesEvent(
                  userId: profile.id,
                ),
              );
            }

            final favoriteBloc = context.read<FavoriteBloc>();

            if (favoriteBloc.state is FavoriteInitial) {
              favoriteBloc.add(
                LoadFavoritesEvent(
                  userId: profile.id,
                ),
              );
            }

            return BlocBuilder<BusinessBloc, BusinessState>(
              builder: (
                context,
                businessState,
              ) {
                if (businessState is BusinessLoading) {
                  return const DashboardSkeleton();
                }

                if (businessState is BusinessError) {
                  return Center(
                    child: Text(
                      businessState.message,
                    ),
                  );
                }

                List<BusinessEntity> businesses = <BusinessEntity>[];

                if (businessState is BusinessFetched) {
                  businesses = businessState.businesses;
                }

                final sorted = [...businesses]
                  ..sort(
                    (a, b) => b.rating.compareTo(a.rating),
                  );

                final topRatedBusinesses = sorted
                    .where(
                      (b) => b.rating > 4.5,
                    )
                    .toList();

                final openNowCandidates = sorted
                    .where(
                      (b) => b.isOpen,
                    )
                    .toList();

                final newestBusinesses = [...businesses]
                  ..sort(
                    (a, b) => b.createdAt.compareTo(a.createdAt),
                  );

                final newestList = newestBusinesses.take(10).toList();

                final juiceShops = sorted
                    .where(
                      (b) => b.type == BusinessType.juice_shop,
                    )
                    .toList();

                const String? sponsoredBannerImageUrl = null;

                return SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ========================================================
                      // HEADER
                      // ========================================================

                      _buildHeader(
                        profile,
                      ),

                      // ========================================================
                      // ONGOING ORDER
                      // ========================================================

                      BlocBuilder<OrderBloc, OrderState>(
                        builder: (
                          context,
                          orderState,
                        ) {
                          if (orderState is! CustomerOrdersFetched) {
                            return const SizedBox.shrink();
                          }

                          final now = DateTime.now();

                          final ongoingOrders = orderState.orders
                              .where(
                                (order) {
                                  if (!order.orderStatus.isOngoing) {
                                    return false;
                                  }

                                  if (order.scheduledFor == null) {
                                    return true;
                                  }

                                  final releaseTime = order.scheduledFor!
                                      .subtract(
                                    const Duration(minutes: 30),
                                  );

                                  return !now.isBefore(releaseTime);
                                },
                              )
                              .toList();

                          if (ongoingOrders.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final order = ongoingOrders.first;

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.pageHorizontal,
                              AppSpacing.xl,
                              AppSpacing.pageHorizontal,
                              0,
                            ),
                            child: _buildFloatingCard(
                              child: OngoingOrderCard(
                                order: order,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderDetailsPage(
                                        order: order,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),

                      // ========================================================
                      // SPONSORED BANNER
                      // ========================================================

                      if (sponsoredBannerImageUrl != null) ...[
                        _sectionTopSpace(),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal,
                          ),
                          child: _buildFloatingCard(
                            child: SponsoredBanner(
                              imageUrl: sponsoredBannerImageUrl,
                              onTap: () {},
                            ),
                          ),
                        ),
                      ],

                      // ========================================================
                      // PROMOTIONS
                      // ========================================================

                      BlocBuilder<PromotionsBloc, PromotionsState>(
                        builder: (
                          context,
                          promoState,
                        ) {
                          if (promoState is PromotionsLoading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.xl,
                              ),
                              child: SizedBox(
                                height: 110,
                                child: ListSkeleton(
                                  itemCount: 2,
                                  showLeadingCircle: false,
                                ),
                              ),
                            );
                          }

                          if (promoState is PromotionsError) {
                            return const SizedBox.shrink();
                          }

                          if (promoState is! PromotionsLoaded ||
                              promoState.promotions.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return _buildPromotionSection(
                            promoState,
                          );
                        },
                      ),

                      // ========================================================
                      // FAVORITES
                      // ========================================================

                      BlocBuilder<FavoriteBloc, FavoriteState>(
                        builder: (
                          context,
                          favoriteState,
                        ) {
                          if (favoriteState is! FavoriteLoaded ||
                              favoriteState.favoriteIds.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final favoriteBusinesses = sorted
                              .where(
                                (b) => favoriteState.favoriteIds.contains(
                                  b.id,
                                ),
                              )
                              .toList();

                          if (favoriteBusinesses.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return _buildBusinessSection(
                            title: 'المفضلة لديك',
                            businesses: favoriteBusinesses,
                          );
                        },
                      ),

                      // ========================================================
                      // TOP RATED
                      // ========================================================

                      if (topRatedBusinesses.isNotEmpty)
                        _buildBusinessSection(
                          title: 'الأعلى تقييمًا',
                          businesses: topRatedBusinesses,
                        ),

                      // ========================================================
                      // NEWEST
                      // ========================================================

                      if (newestList.isNotEmpty)
                        _buildBusinessSection(
                          title: 'الأحدث',
                          businesses: newestList,
                        ),

                      // ========================================================
                      // JUICE SHOPS
                      // ========================================================

                      if (juiceShops.isNotEmpty)
                        _buildBusinessSection(
                          title: 'محلات العصائر',
                          businesses: juiceShops,
                        ),

                      // ========================================================
                      // ALL BUSINESSES
                      // ========================================================

                      if (sorted.isNotEmpty)
                        _buildBusinessSection(
                          title: 'تصفح الكل',
                          businesses: sorted,
                        ),

                      // ========================================================
                      // OPEN NOW
                      // ========================================================

                      if (openNowCandidates.isNotEmpty)
                        _buildOpenNowSection(
                          openNowCandidates,
                        ),

                      const SizedBox(
                        height: 32,
                      ),
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

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader(
    dynamic profile,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeDeliveryHeader(
            addressLabel: _formatAddress(
              profile.address,
            ),
            avatarUrl: profile.photo,
            profileLayerLink: _profileLayerLink,
            profilePulseAnimation: _profilePulseController,
            onAvatarTap: () async {
              _hideProfileHint();

              await context.push('/profile');

              if (context.mounted) {
                context.read<ProfileBloc>().add(
                  GetProfilesEvent(),
                );
              }
            },
            onAddressTap: () => _showAddressBottomSheet(
              context,
              profile.id,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 2,
            ),
            child: HomeGreeting(
              userName: profile.userName,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppRadius.lg,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.035),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: HomeSearchBar(
              onTap: () => context.go('/search'),
              onMicTap: null,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PROMOTIONS
  // ===========================================================================

  Widget _buildPromotionSection(
    PromotionsLoaded promoState,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        top: AppSpacing.xl,
        bottom: AppSpacing.xl,
      ),
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.32),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(
                      AppRadius.full,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: SectionHeader(
                    title: 'عروض وخصومات',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          SizedBox(
            height: PromotionCard.cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                left: AppSpacing.pageHorizontal,
                right: AppSpacing.sm,
              ),
              itemCount: promoState.promotions.length,
              separatorBuilder: (_, __) {
                return const SizedBox(
                  width: AppSpacing.sm,
                );
              },
              itemBuilder: (
                context,
                index,
              ) {
                final promo = promoState.promotions[index];

                return PromotionCard(
                  businessName: promo.businessName,
                  coverUrl: promo.photoUrl,
                  itemName: promo.itemName,
                  label: promo.label,
                  menuItemId: promo.menuItemId,
                  discountPercentage: promo.discountPercentage,
                  oldPrice: promo.oldPrice?.toDouble(),
                  newPrice: promo.newPrice?.toDouble(),
                  onTap: () {
                    if (promo.menuItemId != null) {
                      context.push(
                        '/food/${promo.menuItemId}',
                      );
                    } else {
                      context.push(
                        '/promotion-details',
                        extra: promo,
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BUSINESS SECTION
  // ===========================================================================

  Widget _buildBusinessSection({
    required String title,
    required List<BusinessEntity> businesses,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTopSpace(),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
          child: SectionHeader(
            title: title,
          ),
        ),

        const SizedBox(
          height: 13,
        ),

        SizedBox(
          height: _recommendedRowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: AppSpacing.pageHorizontal,
              right: AppSpacing.sm,
            ),
            itemCount: businesses.length,
            separatorBuilder: (_, __) {
              return const SizedBox(
                width: AppSpacing.sm,
              );
            },
            itemBuilder: (
              context,
              index,
            ) {
              final business = businesses[index];

              return BusinessCard(
                businessId: business.id,
                width: _recommendedTileWidth,
                height: 175,
                compact: true,
                businessName: business.nameAr,
                subtitle:
                    '${_typeLabel(business.type)} · ${_formatAddress(business.adress)}',
                coverUrl: business.coverUrl,
                rating: business.rating,
                ratingCount: business.ratingCount,
                statusText: business.isOpen
                    ? 'مفتوح الآن'
                    : 'مغلق الآن',
                isOpen: business.isOpen,
                onTap: () => context.push(
                  '/business/${business.id}',
                ),
              );
            },
          ),
        ),

        const SizedBox(
          height: AppSpacing.xl,
        ),
      ],
    );
  }

  // ===========================================================================
  // OPEN NOW
  // ===========================================================================

  Widget _buildOpenNowSection(
    List<BusinessEntity> businesses,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        top: 6,
      ),
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.72),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: SectionHeader(
                    title: 'مفتوح الآن',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            itemCount: businesses.length,
            separatorBuilder: (_, __) {
              return const SizedBox(
                height: AppSpacing.md,
              );
            },
            itemBuilder: (
              context,
              index,
            ) {
              final business = businesses[index];

              return BusinessCard(
                businessId: business.id,
                height: 250,
                compact: false,
                businessName: business.nameAr,
                subtitle:
                    '${_typeLabel(business.type)} · ${_formatAddress(business.adress)}',
                coverUrl: business.coverUrl,
                rating: business.rating,
                ratingCount: business.ratingCount,
                statusText: business.isOpen
                    ? 'مفتوح الآن'
                    : 'مغلق الآن',
                isOpen: business.isOpen,
                onTap: () => context.push(
                  '/business/${business.id}',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FLOATING CARD
  // ===========================================================================

  Widget _buildFloatingCard({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.07),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}
