import 'dart:async';

import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/core/utils/delivery_price_utils.dart';
import 'package:aklatna/core/utils/distance_utils.dart';
import 'package:aklatna/features/addresses/domain/entity/addressEntity.dart';
import 'package:aklatna/features/addresses/presentation/bloc/address_bloc.dart';
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

import 'package:aklatna/features/orders/presentation/pages/orderDetailsPage.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
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

    context.read<BusinessBloc>().add(GetBusinesses());
    context.read<PromotionsBloc>().add(LoadPromotionsEvent());

    startPeriodicRebuild();

    _profilePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      lowerBound: 1.0,
      upperBound: 1.08,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

 void _showProfileHint() {
    if (!mounted) return;

    _hideProfileHint();

    _profileTooltipEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          child: CompositedTransformFollower(
            link: _profileLayerLink,
            showWhenUnlinked: false,
            // Anchor top-right of tooltip to bottom-right of avatar
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 6), // Strictly vertical offset
            child: const Material(
              color: Colors.transparent,
              child: ProfileTooltipOverlay(),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_profileTooltipEntry!);

    // Gentle pulse effect
    _profilePulseController
        .repeat(reverse: true, period: const Duration(milliseconds: 450));

    // Stop pulse after 1.8s
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      _profilePulseController.stop();
      _profilePulseController.value = 1.0;
    });

    // Remove tooltip after 3 seconds
    _profileTooltipTimer?.cancel();
    _profileTooltipTimer = Timer(
      const Duration(seconds: 5),
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

  // ============================================================
  // ADDRESS
  // ============================================================

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

  // ============================================================
  // BUSINESS TYPE
  // ============================================================

  String _typeLabel(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return 'مطعم';

      case BusinessType.juice_shop:
        return 'محل عصائر';
    }
  }

  // ============================================================
  // ADDRESS BOTTOM SHEET
  // ============================================================

  void _showAddressBottomSheet(BuildContext context, String userId) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) {
        return AddressSelectionBottomSheet(userId: userId);
      },
    );

    if (!mounted) {
      return;
    }

    context.read<ProfileBloc>().add(GetProfilesEvent());
  }

  // ============================================================
  // DELIVERY FEE
  // ============================================================

  String _deliveryFeeText(BuildContext context, BusinessEntity business) {
    final addressState = context.watch<AddressBloc>().state;

    if (addressState is! AddressLoaded) return 'غير متوفر';

    AddressEntity? defaultAddress;
    for (final address in addressState.addresses) {
      if (address.isDefault) {
        defaultAddress = address;
        break;
      }
    }

    if (defaultAddress == null) return 'غير متوفر';

    final distanceKm = DistanceUtils.calculateDistanceKm(
      customerLatitude: defaultAddress.latitude,
      customerLongitude: defaultAddress.longitude,
      restaurantLatitude: business.latitude,
      restaurantLongitude: business.longitude,
    );

    final price = DeliveryPriceUtils.calculateDeliveryPrice(distanceKm);
    return DeliveryPriceUtils.formatDeliveryPrice(price);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            // ========================================================
            // PROFILE LOADING
            // ========================================================

            if (profileState is ProfileLoading ||
                profileState is ProfileInitial) {
              return const DashboardSkeleton();
            }

            // ========================================================
            // PROFILE ERROR
            // ========================================================

            if (profileState is ProfileError ||
                profileState is! ProfileLoaded) {
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
                      'Profile not found',
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
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final profile = profileState.profile;

            // ========================================================
            // ORDERS
            // ========================================================

            final orderBloc = context.read<OrderBloc>();

            if (orderBloc.state is OrderInitial) {
              orderBloc.add(GetCustomerOrdersEvent(customerId: profile.id));
            }

            // ========================================================
            // ADDRESSES
            // ========================================================

            if (context.read<AddressBloc>().state is AddressInitial) {
              context.read<AddressBloc>().add(
                LoadAddressesEvent(userId: profile.id),
              );
            }

            // ========================================================
            // BUSINESSES
            // ========================================================

            return BlocBuilder<BusinessBloc, BusinessState>(
              builder: (context, businessState) {
                // ====================================================
                // BUSINESS LOADING
                // ====================================================

                if (businessState is BusinessLoading) {
                  return const DashboardSkeleton();
                }

                // ====================================================
                // BUSINESS ERROR
                // ====================================================

                if (businessState is BusinessError) {
                  return Center(child: Text(businessState.message));
                }

                // ====================================================
                // BUSINESS LIST
                // ====================================================

                List<BusinessEntity> businesses = <BusinessEntity>[];

                if (businessState is BusinessFetched) {
                  businesses = businessState.businesses;
                }

                // ====================================================
                // SORT BY RATING
                // ====================================================

                final sorted = [...businesses]
                  ..sort((a, b) => b.rating.compareTo(a.rating));

                // ====================================================
                // TOP RATED
                // ====================================================

                final topRatedBusinesses = sorted
                    .where((b) => b.rating > 4.5)
                    .toList();

                // ====================================================
                // OPEN NOW
                // ====================================================

                final openNowCandidates = sorted
                    .where(
                      (b) =>
                          b.isOpen &&
                          !topRatedBusinesses.any((t) => t.id == b.id),
                    )
                    .toList();

                const String? sponsoredBannerImageUrl = null;

                // ====================================================
                // PAGE
                // ====================================================

                return SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // HEADER
                      // ==================================================
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(AppRadius.xl),
                            bottomRight: Radius.circular(AppRadius.xl),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pageHorizontal,
                          AppSpacing.md,
                          AppSpacing.pageHorizontal,
                          AppSpacing.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HomeDeliveryHeader(
                              addressLabel: _formatAddress(profile.address),
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
                              onAddressTap: () =>
                                  _showAddressBottomSheet(context, profile.id),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            HomeGreeting(userName: profile.userName),
                            const SizedBox(height: AppSpacing.md),
                            HomeSearchBar(
                              onTap: () => context.go('/search'),
                              onMicTap: null,
                            ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // ONGOING ORDER
                      // ==================================================
                      BlocBuilder<OrderBloc, OrderState>(
                        builder: (context, orderState) {
                          if (orderState is! CustomerOrdersFetched) {
                            return const SizedBox.shrink();
                          }

                          final ongoingOrders = orderState.orders.where((
                            order,
                          ) {
                            return order.orderStatus == OrderStatus.pending ||
                                order.orderStatus == OrderStatus.preparing ||
                                order.orderStatus ==
                                    OrderStatus.outForDelivery ||
                                order.orderStatus == OrderStatus.ready;
                          }).toList();

                          if (ongoingOrders.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final order = ongoingOrders.first;

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.pageHorizontal,
                              AppSpacing.lg,
                              AppSpacing.pageHorizontal,
                              0,
                            ),
                            child: OngoingOrderCard(
                              order: order,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        OrderDetailsPage(order: order),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ==================================================
                      // SPONSORED
                      // ==================================================
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

                      // ==================================================
                      // PROMOTIONS
                      // ==================================================
                      BlocBuilder<PromotionsBloc, PromotionsState>(
                        builder: (context, promoState) {
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

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.pageHorizontal,
                                ),
                                child: SectionHeader(title: 'عروض وخصومات'),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(
                                  left: AppSpacing.pageHorizontal,
                                  right: AppSpacing.sm,
                                ),
                                child: Row(
                                  children: [
                                    for (
                                      int i = 0;
                                      i < promoState.promotions.length;
                                      i++
                                    ) ...[
                                      if (i != 0)
                                        const SizedBox(width: AppSpacing.sm),
                                      PromotionCard(
                                        businessName: promoState
                                            .promotions[i]
                                            .businessName,
                                        coverUrl:
                                            promoState.promotions[i].photoUrl,
                                        itemName:
                                            promoState.promotions[i].itemName,
                                        discountPercentage: promoState
                                            .promotions[i]
                                            .discountPercentage,
                                        oldPrice: promoState
                                            .promotions[i]
                                            .oldPrice
                                            ?.toDouble(),
                                        newPrice: promoState
                                            .promotions[i]
                                            .newPrice
                                            ?.toDouble(),
                                        onTap: () {
  final promo = promoState.promotions[i]; // أو businessPromotions[index]
  if (promo.menuItemId != null) {
    context.push('/food/${promo.menuItemId}');
  } else {
context.push('/promotion-details', extra: promo);    // أو اعمل صفحة تفاصيل عرض مستقلة لاحقا
  }
},
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                          );
                        },
                      ),

                      // ==================================================
                      // TOP RATED
                      // ==================================================
                      if (topRatedBusinesses.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal,
                          ),
                          child: SectionHeader(title: 'الأعلى تقييمًا'),
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
                            itemCount: topRatedBusinesses.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final business = topRatedBusinesses[index];

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
                                deliveryFeeText: _deliveryFeeText(
                                  context,
                                  business,
                                ),
                                onTap: () =>
                                    context.push('/business/${business.id}'),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // ==================================================
                      // OPEN NOW
                      // ==================================================
                      if (openNowCandidates.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal,
                          ),
                          child: SectionHeader(title: 'مفتوح الآن'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal,
                          ),
                          itemCount: openNowCandidates.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final business = openNowCandidates[index];

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
                              deliveryFeeText: _deliveryFeeText(
                                context,
                                business,
                              ),
                              onTap: () =>
                                  context.push('/business/${business.id}'),
                            );
                          },
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