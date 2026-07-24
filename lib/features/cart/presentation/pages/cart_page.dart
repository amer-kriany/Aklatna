import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_state.dart';
import 'package:aklatna/features/cart/presentation/widgets/cart/CartCheckoutButton.dart';
import 'package:aklatna/features/cart/presentation/widgets/cart/CartDeliveryAddressSection.dart';
import 'package:aklatna/features/cart/presentation/widgets/cart/CartSummarySection.dart';
import 'package:aklatna/features/cart/presentation/widgets/cart/cartItemCard.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';

/// No constructor params — matches HomePage/SearchPage convention.
class CartPage extends StatelessWidget {
  const CartPage({super.key});

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
              Text('سلتي', style: AppTextStyles.h2), // "My Cart"
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
                              onIncrement: () => context.read<CartBloc>().add(
                                AddItemEvent(item: item.copyWith(quantity: 1)),
                              ),
                              onDecrement: () => context.read<CartBloc>().add(
                                RemoveItemEvent(itemId: item.itemId),
                              ),
                              onRemove: () {
                                for (int i = 0; i < item.quantity; i++) {
                                  context.read<CartBloc>().add(
                                    RemoveItemEvent(itemId: item.itemId),
                                  );
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),
                        const Divider(),
                        const SizedBox(height: AppSpacing.md),

                        CartSummarySection(subTotal: cartState.totalPrice),

                        const SizedBox(height: AppSpacing.lg),
                        const Divider(),
                        const SizedBox(height: AppSpacing.lg),

                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, profileState) {
                            final address = profileState is ProfileLoaded
                                ? profileState.profile.address
                                : '';
                            final userId = profileState is ProfileLoaded
                                ? profileState.profile.id
                                : '';

                            const orderType = 'delivery';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (orderType == 'delivery') ...[
                                  CartDeliveryAddressSection(
                                    address: address.isNotEmpty
                                        ? address
                                        : 'لا يوجد عنوان محفوظ',
                                    userId: userId,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                ],
                                CartCheckoutButton(
                                  onPressed: () {
                                    context.push("/checkout");
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}