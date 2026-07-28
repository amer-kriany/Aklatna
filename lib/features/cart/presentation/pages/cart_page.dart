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

  void _showActiveOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'لديك طلب قيد التنفيذ',
          style: AppTextStyles.h4,
          textAlign: TextAlign.center,
        ),
        content: Text(
          'لا يمكنك إنشاء طلب جديد حتى يكتمل أو يُلغى طلبك الحالي.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'حسناً',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMissingAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'العنوان مفقود',
          style: AppTextStyles.h4,
          textAlign: TextAlign.center,
        ),
        content: Text(
          'يرجى إضافة عنوان توصيل حتى تتمكن من إكمال الطلب.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'إلغاء',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push('/addresses');
            },
            child: Text(
              'إضافة عنوان',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
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

              Text(
                'سلتي',
                style: AppTextStyles.h2,
              ),

              const SizedBox(height: AppSpacing.lg),

              Expanded(
                child: BlocBuilder<CartBloc, CartState>(
                  builder: (context, cartState) {
                    if (cartState.items.isEmpty) {
                      return Center(
                        child: Text(
                          'السلة فارغة',
                          style: AppTextStyles.bodyMedium,
                        ),
                      );
                    }

                return BlocBuilder<AddressBloc, AddressState>(
                  builder: (context, addressState) {
                    return BlocBuilder<BusinessBloc, BusinessState>(
                      builder: (context, businessState) {
                        // ============================================
                        // DISTANCE CALC (once per cart, same for
                        // every item since one restaurant per cart)
                        // ============================================

                        String? distanceText;

                        AddressEntity? defaultAddress;

                        if (addressState is AddressLoaded) {
                          for (final address in addressState.addresses) {
                            if (address.isDefault) {
                              defaultAddress = address;
                              break;
                            }
                          }
                        }

                        if (defaultAddress != null &&
                            businessState is BusinessFetched) {
                          for (final business
                              in businessState.businesses) {
                            if (business.id == cartState.businessId) {
                              final distanceKm =
                                  DistanceUtils.calculateDistanceKm(
                                customerLatitude:
                                    defaultAddress.latitude,
                                customerLongitude:
                                    defaultAddress.longitude,
                                restaurantLatitude: business.latitude,
                                restaurantLongitude:
                                    business.longitude,
                              );

                              distanceText =
                                  DistanceUtils.formatDistance(
                                distanceKm,
                              );
                              break;
                            }
                          }
                        }

                        return ListView(
                          children: [
                            ...cartState.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: CartItemCard(
                                  photoUrl: item.photoUrl,
                                  nameAr: item.nameAr,
                                  description: item.description,
                                  price: item.price,
                                  quantity: item.quantity,

                                  onIncrement: () {
                                    context.read<CartBloc>().add(
                                      AddItemEvent(
                                        item: item.copyWith(
                                          quantity: 1,
                                        ),
                                      ),
                                    );
                                  },

                                  onDecrement: () {
                                    context.read<CartBloc>().add(
                                      RemoveItemEvent(
                                        itemId: item.itemId,
                                      ),
                                    );
                                  },

                                  onRemove: () {
                                    for (int i = 0;
                                        i < item.quantity;
                                        i++) {
                                      context.read<CartBloc>().add(
                                        RemoveItemEvent(
                                          itemId: item.itemId,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),

                            // ============================================
                            // DISTANCE ROW (one per cart, not per item)
                            // ============================================
                            //
                            // TODO: predicted delivery time goes on the
                            // right side of this same row once that
                            // feature is built.
                            // ============================================

                            if (distanceText != null) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'المسافة: $distanceText',
                                          style: AppTextStyles
                                              .regularMedium
                                              .copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Reserved for predicted delivery
                                    // time — leave empty for now.
                                    const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: AppSpacing.md),
                            const Divider(),
                            const SizedBox(height: AppSpacing.md),

                            CartSummarySection(
                              subTotal: cartState.totalPrice,
                            ),

                            const SizedBox(height: AppSpacing.lg),
                            const Divider(),
                            const SizedBox(height: AppSpacing.lg),

                            BlocBuilder<ProfileBloc, ProfileState>(
                              builder: (context, profileState) {
                                final profile =
                                    profileState is ProfileLoaded
                                        ? profileState.profile
                                        : null;

                                final userId = profile?.id ?? '';

                                const orderType = 'delivery';

                                // Load addresses the first time we
                                // have a valid profile, in case the
                                // user navigated straight to Cart
                                // without ever visiting AddressesPage
                                // or opening the address bottom sheet
                                // on Home.
                                if (profile != null &&
                                    context.read<AddressBloc>().state
                                        is AddressInitial) {
                                  context.read<AddressBloc>().add(
                                        LoadAddressesEvent(
                                          userId: profile.id,
                                        ),
                                      );
                                }

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    if (orderType == 'delivery') ...[
                                      CartDeliveryAddressSection(
                                        userId: userId,
                                      ),

                                      const SizedBox(
                                        height: AppSpacing.lg,
                                      ),
                                    ],

                                    CartCheckoutButton(
                                      onPressed: () {
                                        // 1. Check active order
                                        final orderState = context
                                            .read<OrderBloc>()
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

                                        // 2. Check default address
                                        final addressState = context
                                            .read<AddressBloc>()
                                            .state;

                                        if (orderType == 'delivery') {
                                          bool hasDefaultAddress =
                                              false;

                                          if (addressState
                                              is AddressLoaded) {
                                            hasDefaultAddress =
                                                addressState.addresses
                                                    .any(
                                              (address) =>
                                                  address.isDefault,
                                            );
                                          }

                                          if (!hasDefaultAddress) {
                                            _showMissingAddressDialog(
                                              context,
                                            );
                                            return;
                                          }
                                        }

                                        // 3. Everything is ready
                                        context.push('/checkout');
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: AppSpacing.lg),
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
      ),
    );
  }
}