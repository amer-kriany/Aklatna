import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/cart/presentation/widgets/checkout/CheckoutAppBar.dart';
import 'package:aklatna/features/cart/presentation/widgets/checkout/ConfirmButton.dart';
import 'package:aklatna/features/cart/presentation/widgets/checkout/DeliveryOptionSection.dart';
import 'package:aklatna/features/cart/presentation/widgets/checkout/OrderTypeSection.dart';
import 'package:aklatna/features/orders/data/models/order_model.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:aklatna/features/orders/order_type.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// TODO: Import your constant files
// import 'package:your_app/core/constants/app_colors.dart';
// import 'package:your_app/core/constants/app_spacing.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedDeliveryOption = 'توصيل';
  String selectedOrderType = 'طلب عادي';

  void _onConfirm() {
    final cartState = context.read<CartBloc>().state;
    final profileState = context.read<ProfileBloc>().state;
    

    if (cartState.items.isEmpty || profileState is! ProfileLoaded || cartState.businessId == null) {
      return; // TODO(Amer): show real error
    }

    final profile = profileState.profile;

   final order = OrderEntity(
  businessId: cartState.businessId!,
  customerId: profile.id,
  customername: profile.userName,
  customerPhone: profile.phoneNumber,
  items: cartState.items,
  deliveryAddress: selectedDeliveryOption == 'توصيل' ? profile.address : null,
  totalPrice: cartState.totalPrice,
  orderType: selectedDeliveryOption == 'توصيل' ? OrderType.delivery : OrderType.pickup,
  orderStatus: OrderStatus.pending,
);

    context.read<OrderBloc>().add(PlaceOrderEvent(order: order));
     if (OrderState is OrderPlacing) return;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocListener<OrderBloc, OrderState>(
            listener: (context, state) {
              if (state is OrderPlaced) {
                context.read<CartBloc>().add(ClearCartEvent());
                Navigator.pop(context); // TODO(Amer): navigate to confirmation screen?
              }
              if (state is OrderError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckoutAppBar(onBackTap: () => Navigator.pop(context)),
                  const Spacer(flex: 1),
                  DeliveryOptionSection(
                    selectedOption: selectedDeliveryOption,
                    onOptionChanged: (v) => setState(() => selectedDeliveryOption = v),
                  ),
                  const Spacer(flex: 1),
                  OrderTypeSection(
                    selectedOption: selectedOrderType,
                    onOptionChanged: (v) => setState(() => selectedOrderType = v),
                  ),
                  const Spacer(flex: 4),
                  BlocBuilder<OrderBloc, OrderState>(
                    builder: (context, state) {
                      return ConfirmButton(
                        onConfirm: state is OrderPlacing ? (){} : _onConfirm,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}