import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';

import 'package:aklatna/features/home/presentation/widgets/home/AddressSelectionBottomSheet.dart';
import 'package:aklatna/features/home/presentation/widgets/home/BusinessCard.dart';
import 'package:aklatna/features/home/presentation/widgets/home/HomeDeliveryHeader.dart';
import 'package:aklatna/features/home/presentation/widgets/home/HomeGreeting.dart';
import 'package:aklatna/features/home/presentation/widgets/home/HomeSearchBar.dart';
import 'package:aklatna/features/home/presentation/widgets/home/SectionHeader.dart';
import 'package:aklatna/features/home/presentation/widgets/home/SponseredBanner.dart';
import 'package:aklatna/features/orders/presentation/pages/orderDetailsPage.dart';
import 'package:aklatna/features/orders/presentation/widgets/orderStatusHelper.dart';

import 'package:aklatna/features/promotions/presentaion/bloc/promotions_bloc.dart';
import 'package:aklatna/features/promotions/presentaion/widgets/promotionCard.dart';

import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../business_type.dart';
import '../../domain/entity/businessEntity.dart';
import '../bloc/business_bloc.dart';
import '../../../profile/presentaion/bloc/profile_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _recommendedTileWidth = 160;
  static const double _recommendedRowHeight = 220;

  @override
  void initState() {
    super.initState();

    context.read<BusinessBloc>().add(GetBusinesses());
    context.read<ProfileBloc>().add(GetProfilesEvent());
    context.read<PromotionsBloc>().add(LoadPromotionsEvent());
  }

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

  void _showAddressBottomSheet(
    BuildContext context,
    String userId,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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

    if (mounted) {
      context.read<ProfileBloc>().add(
            GetProfilesEvent(),
          );
    }
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
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

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
                      "Profile not found",
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
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            final profile = profileState.profile;

            // Make sure orders are loaded for the homepage.
            final orderBloc = context.read<OrderBloc>();

            if (orderBloc.state is OrderInitial) {
              orderBloc.add(
                GetCustomerOrdersEvent(
                  customerId: profile.id,
                ),
              );
            }

            return BlocBuilder<BusinessBloc, BusinessState>(
              builder: (context, businessState) {
                if (businessState is BusinessLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
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

                final popularBusiness =
                    sorted.isNotEmpty ? sorted.first : null;

                final recommendedBusinesses = sorted.length > 1
                    ? sorted.sublist(1)
                    : <BusinessEntity>[];

                const String? sponsoredBannerImageUrl = null;

                return SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =====================================================
                      // HEADER
                      // =====================================================

                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(
                              AppRadius.xl,
                            ),
                            bottomRight: Radius.circular(
                              AppRadius.xl,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pageHorizontal,
                          AppSpacing.md,
                          AppSpacing.pageHorizontal,
                          AppSpacing.lg,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            HomeDeliveryHeader(
                              addressLabel:
                                  _formatAddress(profile.address),
                              avatarUrl: profile.photo,
                              onAvatarTap: () async {
                                await context.push("/profile");

                                if (context.mounted) {
                                  context.read<ProfileBloc>().add(
                                        GetProfilesEvent(),
                                      );
                                }
                              },
                              onAddressTap: () =>
                                  _showAddressBottomSheet(
                                context,
                                profile.id,
                              ),
                            ),

                            const SizedBox(
                              height: AppSpacing.lg,
                            ),

                            HomeGreeting(
                              userName: profile.userName,
                            ),

                            const SizedBox(
                              height: AppSpacing.md,
                            ),

                            HomeSearchBar(
                              onTap: () => context.go("/search"),
                              onMicTap: null,
                            ),
                          ],
                        ),
                      ),

                      // =====================================================
                      // ONGOING ORDER
                      // =====================================================

                     BlocBuilder<OrderBloc, OrderState>(
  builder: (context, orderState) {
    if (orderState is! CustomerOrdersFetched) {
      return const SizedBox.shrink();
    }

    final ongoingOrders = orderState.orders.where((order) {
      return order.orderStatus == OrderStatus.pending ||
          order.orderStatus == OrderStatus.preparing ||
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
      child: _OngoingOrderCard(
        order: order,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsPage(order: order),
            ),
          );
        },
      ),
    );
  },
),

                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      // =====================================================
                      // SPONSORED BANNER
                      // =====================================================

                      if (sponsoredBannerImageUrl != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal:
                                AppSpacing.pageHorizontal,
                          ),
                          child: SponsoredBanner(
                            imageUrl:
                                sponsoredBannerImageUrl,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                      ],

                      // =====================================================
                      // PROMOTIONS
                      // =====================================================

                      BlocBuilder<PromotionsBloc, PromotionsState>(
                        builder: (context, promoState) {
                          if (promoState is PromotionsLoading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.xl,
                              ),
                              child: Center(
                                child:
                                    CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (promoState is PromotionsError) {
                            return const SizedBox.shrink();
                          }

                          if (promoState
                                  is! PromotionsLoaded ||
                              promoState.promotions.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppSpacing.pageHorizontal,
                                ),
                                child: SectionHeader(
                                  title: 'عروض وخصومات',
                                ),
                              ),

                              const SizedBox(
                                height: AppSpacing.md,
                              ),

                              SingleChildScrollView(
                                scrollDirection:
                                    Axis.horizontal,
                                padding: const EdgeInsets.only(
                                  left: AppSpacing.pageHorizontal,
                                  right: AppSpacing.sm,
                                ),
                                child: Row(
                                  children: [
                                    for (
                                      int i = 0;
                                      i <
                                          promoState
                                              .promotions.length;
                                      i++
                                    ) ...[
                                      if (i != 0)
                                        const SizedBox(
                                          width:
                                              AppSpacing.sm,
                                        ),

                                      PromotionCard(
                                        businessName:
                                            promoState
                                                .promotions[i]
                                                .businessName,
                                        coverUrl:
                                            promoState
                                                .promotions[i]
                                                .photoUrl,
                                        itemName:
                                            promoState
                                                .promotions[i]
                                                .itemName,
                                        discountPercentage:
                                            promoState
                                                .promotions[i]
                                                .discountPercentage,
                                        oldPrice:
                                            promoState
                                                .promotions[i]
                                                .oldPrice,
                                        newPrice:
                                            promoState
                                                .promotions[i]
                                                .newPrice,
                                        onTap: () {
                                          context.push(
                                            "/business/${promoState.promotions[i].businessId}",
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(
                                height: AppSpacing.xl,
                              ),
                            ],
                          );
                        },
                      ),

                      // =====================================================
                      // RECOMMENDED
                      // =====================================================

                      if (recommendedBusinesses.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                AppSpacing.pageHorizontal,
                          ),
                          child: SectionHeader(
                            title: 'موصى لك',
                          ),
                        ),

                        const SizedBox(
                          height: AppSpacing.md,
                        ),

                        SizedBox(
                          height: _recommendedRowHeight,
                          child: ListView.separated(
                            scrollDirection:
                                Axis.horizontal,
                            padding: const EdgeInsets.only(
                              left:
                                  AppSpacing.pageHorizontal,
                              right: AppSpacing.sm,
                            ),
                            itemCount:
                                recommendedBusinesses.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(
                              width: AppSpacing.sm,
                            ),
                            itemBuilder: (
                              context,
                              index,
                            ) {
                              final business =
                                  recommendedBusinesses[
                                      index];

                              return BusinessCard(
                                businessId: business.id,
                                width:
                                    _recommendedTileWidth,
                                height: 150,
                                compact: true,
                                businessName:
                                    business.nameAr,
                                subtitle:
                                    '${_typeLabel(business.type)} · ${_formatAddress(business.adress)}',
                                coverUrl:
                                    business.coverUrl,
                                rating:
                                    business.rating,
                                ratingCount:
                                    business.ratingCount,
                                imageAspectRatio: 1.15,
                                statusText:
                                    business.isOpen
                                        ? 'مفتوح الآن'
                                        : 'مغلق الآن',
                                deliveryFeeText:
                                    'توصيل 5,000',
                                onTap: () {
                                  context.push(
                                    "/business/${business.id}",
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                      ],

                      // =====================================================
                      // MOST ORDERED
                      // =====================================================

                      if (popularBusiness != null) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                AppSpacing.pageHorizontal,
                          ),
                          child: SectionHeader(
                            title: 'الأكثر طلبًا',
                          ),
                        ),

                        const SizedBox(
                          height: AppSpacing.md,
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal:
                                AppSpacing.pageHorizontal,
                          ),
                          child: BusinessCard(
                            businessId:
                                popularBusiness.id,
                            businessName:
                                popularBusiness.nameAr,
                            subtitle:
                                '${_typeLabel(popularBusiness.type)} · ${_formatAddress(popularBusiness.adress)}',
                            coverUrl:
                                popularBusiness.coverUrl,
                            rating:
                                popularBusiness.rating,
                            ratingCount:
                                popularBusiness.ratingCount,
                            imageAspectRatio: 3.4,
                            height: 250,
                            compact: false,
                            statusText:
                                popularBusiness.isOpen
                                    ? 'مفتوح الآن'
                                    : 'مغلق الآن',
                            deliveryFeeText:
                                'توصيل 5,000',
                            onTap: () {
                              context.push(
                                "/business/${popularBusiness.id}",
                              );
                            },
                          ),
                        ),

                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
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

// ===========================================================================
// ONGOING ORDER CARD
// ===========================================================================

class _OngoingOrderCard extends StatelessWidget {
  const _OngoingOrderCard({
    required this.order,
    required this.onTap,
  });

  final dynamic order;
  final VoidCallback onTap;

  String _statusText(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'بانتظار المطعم';

    case OrderStatus.preparing:
      return 'جاري تحضير طلبك';

    case OrderStatus.ready:
      return 'طلبك جاهز';

    case OrderStatus.completed:
      return 'تم إكمال الطلب';

    case OrderStatus.cancelled:
      return 'تم إلغاء الطلب';
  }
}

IconData _statusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return Icons.access_time_rounded;

    case OrderStatus.preparing:
      return Icons.restaurant_rounded;

    case OrderStatus.ready:
      return Icons.inventory_2_outlined;

    case OrderStatus.completed:
      return Icons.check_circle_rounded;

    case OrderStatus.cancelled:
      return Icons.cancel_outlined;
  }
}
 

  @override
  Widget build(BuildContext context) {
    final status = order.orderStatus;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              AppRadius.xl,
            ),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(
                    AppRadius.lg,
                  ),
                ),
                child: Icon(
                  _statusIcon(status),
                  color: AppColors.primary,
                  size: 25,
                ),
              ),

              const SizedBox(
                width: AppSpacing.md,
              ),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلبك الجاري',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppTextStyles.caption.copyWith(
                        color:
                            AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      _statusText(status),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppTextStyles.bodyMedium.copyWith(
                        color:
                            AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    if (order.businessName != null &&
                        order.businessName
                            .toString()
                            .isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        order.businessName.toString(),
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            AppTextStyles.caption.copyWith(
                          color:
                              AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              // Arrow
              const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}