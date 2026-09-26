import 'package:aklatna/features/addresses/domain/entity/addressEntity.dart';
import 'package:aklatna/features/addresses/presentation/bloc/address_bloc.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_state.dart';
import 'package:aklatna/features/cart/presentation/widgets/cart/CartCheckoutButton.dart';
import 'package:aklatna/features/cart/presentation/widgets/cart/CartDeliveryAddressSection.dart';
import 'package:aklatna/features/cart/presentation/widgets/cart/CartSummarySection.dart';
import 'package:aklatna/features/cart/presentation/widgets/cart/cartItemCard.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:aklatna/core/utils/distance_utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // ===========================================================================
  // ACTIVE ORDER DIALOG
  // ===========================================================================

  void _showActiveOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppRadius.xl,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delivery_dining_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              Text(
                'لديك طلب قيد التنفيذ',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: AppSpacing.sm,
              ),

              Text(
                'لا يمكنك إنشاء طلب جديد حتى يكتمل أو يُلغى طلبك الحالي.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppRadius.md,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'حسناً',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // MISSING ADDRESS DIALOG
  // ===========================================================================

  void _showMissingAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppRadius.xl,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              Text(
                'أين نوصّل طلبك؟',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: AppSpacing.sm,
              ),

              Text(
                'أضف عنوان توصيل حتى نتمكن من إيصال طلبك إليك.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: Text(
                        'لاحقاً',
                        style:
                            AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: AppSpacing.sm,
                  ),

                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primary,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            AppRadius.md,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);

                        context.push(
                          '/addresses',
                        );
                      },
                      child: Text(
                        'إضافة عنوان',
                        style:
                            AppTextStyles.buttonMedium
                                .copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // EMPTY CART
  // ===========================================================================

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 52,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              'سلتك فارغة',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Text(
              'لم تضف أي أطباق بعد.\nاكتشف المطاعم واختر وجبتك المفضلة.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            SizedBox(
              width: 190,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/home');
                },
                icon: const Icon(
                  Icons.restaurant_menu_rounded,
                  size: 20,
                ),
                label: Text(
                  'اكتشف الأطباق',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppRadius.md,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Text(
            'سلتي',
            style: AppTextStyles.h2,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // RESTAURANT INFO
  // ===========================================================================

  Widget _buildRestaurantHeader(
    BuildContext context,
    CartState cartState,
    BusinessState businessState,
  ) {
    if (businessState is! BusinessFetched) {
      return const SizedBox.shrink();
    }

    for (final business in businessState.businesses) {
      if (business.id != cartState.businessId) {
        continue;
      }

      return Container(
        margin: const EdgeInsets.only(
          bottom: AppSpacing.lg,
        ),
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
            AppRadius.lg,
          ),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
              child: SizedBox(
                width: 54,
                height: 54,
                child: business.logoUrl != null &&
                        business.logoUrl!.isNotEmpty
                    ? Image.network(
                        business.logoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Container(
                            color: AppColors.background,
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.background,
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),

            const SizedBox(
              width: AppSpacing.md,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    business.nameAr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h4,
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),

                      const SizedBox(
                        width: 4,
                      ),

                      Text(
                        business.rating
                            .toStringAsFixed(1),
                        style:
                            AppTextStyles.regularMedium
                                .copyWith(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Container(
                        width: 4,
                        height: 4,
                        decoration:
                            const BoxDecoration(
                          color:
                              AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Text(
                        business.isOpen
                            ? 'مفتوح الآن'
                            : 'مغلق الآن',
                        style:
                            AppTextStyles.regularMedium
                                .copyWith(
                          color: business.isOpen
                              ? Colors.green
                              : AppColors
                                  .textSecondary,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ===========================================================================
  // DISTANCE
  // ===========================================================================

  Widget _buildDistance(
    String distanceText,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: AppSpacing.lg,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(
            width: AppSpacing.sm,
          ),

          Text(
            'المسافة إلى المطعم',
            style: AppTextStyles.regularMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const Spacer(),

          Text(
            distanceText,
            style: AppTextStyles.regularMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ITEMS HEADER
  // ===========================================================================

  Widget _buildItemsHeader(
    int itemCount,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.md,
      ),
      child: Row(
        children: [
          Text(
            'طلبك',
            style: AppTextStyles.h4,
          ),

          const SizedBox(
            width: AppSpacing.sm,
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppRadius.full,
              ),
            ),
            child: Text(
              '$itemCount',
              style: AppTextStyles.regularMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal:
                    AppSpacing.pageHorizontal,
              ),
              child: _buildHeader(),
            ),

            Expanded(
              child:
                  BlocBuilder<CartBloc, CartState>(
                builder: (
                  context,
                  cartState,
                ) {
                  // ==========================================================
                  // EMPTY
                  // ==========================================================

                  if (cartState.items.isEmpty) {
                    return _buildEmptyCart(
                      context,
                    );
                  }

                  // ==========================================================
                  // ADDRESS
                  // ==========================================================

                  return BlocBuilder<
                      AddressBloc,
                      AddressState>(
                    builder: (
                      context,
                      addressState,
                    ) {
                      // ========================================================
                      // BUSINESS
                      // ========================================================

                      return BlocBuilder<
                          BusinessBloc,
                          BusinessState>(
                        builder: (
                          context,
                          businessState,
                        ) {
                          String? distanceText;

                          AddressEntity?
                              defaultAddress;

                          // ====================================================
                          // DEFAULT ADDRESS
                          // ====================================================

                          if (addressState
                              is AddressLoaded) {
                            for (final address
                                in addressState
                                    .addresses) {
                              if (address
                                  .isDefault) {
                                defaultAddress =
                                    address;
                                break;
                              }
                            }
                          }

                          // ====================================================
                          // DISTANCE
                          // ====================================================

                          if (defaultAddress != null &&
                              businessState
                                  is BusinessFetched) {
                            for (final business
                                in businessState
                                    .businesses) {
                              if (business.id ==
                                  cartState
                                      .businessId) {
                                final distanceKm =
                                    DistanceUtils
                                        .calculateDistanceKm(
                                  customerLatitude:
                                      defaultAddress
                                          .latitude,
                                  customerLongitude:
                                      defaultAddress
                                          .longitude,
                                  restaurantLatitude:
                                      business
                                          .latitude,
                                  restaurantLongitude:
                                      business
                                          .longitude,
                                );

                                distanceText =
                                    DistanceUtils
                                        .formatDistance(
                                  distanceKm,
                                );

                                break;
                              }
                            }
                          }

                          // ====================================================
                          // CONTENT
                          // ====================================================

                          return ListView(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal:
                                  AppSpacing
                                      .pageHorizontal,
                            ),
                            physics:
                                const BouncingScrollPhysics(),
                            children: [
                              // ================================================
                              // RESTAURANT
                              // ================================================

                              _buildRestaurantHeader(
                                context,
                                cartState,
                                businessState,
                              ),

                              // ================================================
                              // ITEMS
                              // ================================================

                              _buildItemsHeader(
                                cartState.items
                                    .fold<int>(
                                  0,
                                  (
                                    sum,
                                    item,
                                  ) =>
                                      sum +
                                      item.quantity,
                                ),
                              ),

                              ...cartState.items.map(
                                (item) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets
                                            .only(
                                      bottom:
                                          AppSpacing
                                              .md,
                                    ),
                                    child:
                                        CartItemCard(
                                      photoUrl:
                                          item.photoUrl,
                                      nameAr:
                                          item.nameAr,
                                      description:
                                          item.description,
                                      price:
                                          item.price,
                                      quantity:
                                          item.quantity,

                                      onIncrement:
                                          () {
                                        context
                                            .read<
                                                CartBloc>()
                                            .add(
                                              AddItemEvent(
                                                item:
                                                    item.copyWith(
                                                  quantity:
                                                      1,
                                                ),
                                              ),
                                            );
                                      },

                                      onDecrement:
                                          () {
                                        context
                                            .read<
                                                CartBloc>()
                                            .add(
                                              RemoveItemEvent(
                                                itemId:
                                                    item.itemId,
                                              ),
                                            );
                                      },

                                      onRemove: () {
                                        for (
                                          int i = 0;
                                          i <
                                              item
                                                  .quantity;
                                          i++
                                        ) {
                                          context
                                              .read<
                                                  CartBloc>()
                                              .add(
                                                RemoveItemEvent(
                                                  itemId:
                                                      item.itemId,
                                                ),
                                              );
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),

                              // ================================================
                              // DISTANCE
                              // ================================================

                              if (distanceText !=
                                  null)
                                _buildDistance(
                                  distanceText,
                                ),

                              // ================================================
                              // SUMMARY
                              // ================================================

                              Container(
                                padding:
                                    const EdgeInsets
                                        .all(
                                  AppSpacing.md,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      AppColors.surface,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    AppRadius.lg,
                                  ),
                                  border:
                                      Border.all(
                                    color:
                                        AppColors
                                            .border,
                                  ),
                                ),
                                child:
                                    CartSummarySection(
                                  subTotal:
                                      cartState
                                          .totalPrice,
                                  itemCount:
                                      cartState.items
                                          .fold<int>(
                                    0,
                                    (
                                      sum,
                                      item,
                                    ) =>
                                        sum +
                                        item.quantity,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height:
                                    AppSpacing.lg,
                              ),

                              // ================================================
                              // DELIVERY
                              // ================================================

                              BlocBuilder<
                                  ProfileBloc,
                                  ProfileState>(
                                builder: (
                                  context,
                                  profileState,
                                ) {
                                  final profile =
                                      profileState
                                              is ProfileLoaded
                                          ? profileState
                                              .profile
                                          : null;

                                  final userId =
                                      profile?.id ??
                                          '';

                                  // --------------------------------------------
                                  // LOAD ADDRESSES
                                  // --------------------------------------------

                                  if (profile !=
                                          null &&
                                      context
                                              .read<
                                                  AddressBloc>()
                                              .state
                                          is AddressInitial) {
                                    context
                                        .read<
                                            AddressBloc>()
                                        .add(
                                          LoadAddressesEvent(
                                            userId:
                                                profile.id,
                                          ),
                                        );
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        'التوصيل',
                                        style:
                                            AppTextStyles
                                                .h4,
                                      ),

                                      const SizedBox(
                                        height:
                                            AppSpacing
                                                .md,
                                      ),

                                      const CartDeliveryAddressSection(
                                        userId: '',
                                      ),

                                      const SizedBox(
                                        height:
                                            AppSpacing
                                                .lg,
                                      ),

                                      // ========================================
                                      // CHECKOUT
                                      // ========================================

                                      BlocBuilder<
                                          AddressBloc,
                                          AddressState>(
                                        builder: (
                                          context,
                                          latestAddressState,
                                        ) {
                                          return CartCheckoutButton(
                                            onPressed:
                                                () {
                                              // --------------------------------
                                              // ACTIVE ORDER
                                              // --------------------------------

                                              final orderState =
                                                  context
                                                      .read<
                                                          OrderBloc>()
                                                      .state;

                                              if (orderState
                                                      is CustomerOrdersFetched &&
                                                  orderState
                                                      .hasActiveOrder) {
                                                _showActiveOrderDialog(
                                                  context,
                                                );
                                                return;
                                              }

                                              // --------------------------------
                                              // ADDRESS
                                              // --------------------------------

                                              bool
                                                  hasDefaultAddress =
                                                  false;

                                              if (latestAddressState
                                                  is AddressLoaded) {
                                                hasDefaultAddress =
                                                    latestAddressState
                                                        .addresses
                                                        .any(
                                                  (
                                                    address,
                                                  ) =>
                                                      address
                                                          .isDefault,
                                                );
                                              }

                                              if (!hasDefaultAddress) {
                                                _showMissingAddressDialog(
                                                  context,
                                                );
                                                return;
                                              }

                                              // --------------------------------
                                              // CHECKOUT
                                              // --------------------------------

                                              context
                                                  .push(
                                                '/checkout',
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(
                                height:
                                    AppSpacing.xl,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}