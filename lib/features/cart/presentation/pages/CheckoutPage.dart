import 'package:aklatna/features/cart/presentation/widgets/checkout/orderCountDownDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/distance_utils.dart';
import '../../../../core/utils/delivery_price_utils.dart';
import '../../../addresses/domain/entity/addressEntity.dart';
import '../../../addresses/presentation/bloc/address_bloc.dart';
import '../../../home/presentation/bloc/business_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/widgets/checkout/CheckoutAppBar.dart';
import '../../../cart/presentation/widgets/checkout/ConfirmButton.dart';
import '../../../cart/presentation/widgets/checkout/DeliveryOptionSection.dart';
import '../../../cart/presentation/widgets/checkout/OrderTypeSection.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/orderStatus.dart';
import '../../../orders/order_type.dart';
import '../../../orders/presentation/bloc/order_bloc.dart';
import '../../../profile/presentaion/bloc/profile_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedDeliveryOption = 'توصيل';
  String selectedOrderType = 'طلب عادي';
  DateTime? _scheduledFor;
  final TextEditingController _notesController = TextEditingController();
  bool _blockIfRestaurantNowClosed(BuildContext context, String businessId) {
    final businessState = context.read<BusinessBloc>().state;

    if (businessState is! BusinessFetched) return false;

    for (final business in businessState.businesses) {
      if (business.id == businessId) {
        if (!business.isOpen) {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              title: Text(
                'المطعم مغلق الآن',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              content: Text(
                'المطعم مغلق. لا يمكن إتمام الطلب حالياً',
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
          return true;
        }
        break;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickScheduleTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;

    final now = DateTime.now();
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );

    if (scheduled.isBefore(now)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الوقت المختار مضى بالفعل')));
      return;
    }

    setState(() => _scheduledFor = scheduled);
  }

  // ============================================================
  // DELIVERY PRICE CALC
  // ============================================================
  //
  // Same pattern used in CartPage: distance from customer's default
  // address to the business, converted to a price via
  // DeliveryPriceUtils. Returns 0 (not null) if pickup or if location
  // data is unavailable, since this feeds directly into total_price
  // which is stored in the DB — a null there would be a real bug.
  // ============================================================

  double _calculateDeliveryPrice(BuildContext context, String businessId) {
    if (selectedDeliveryOption != 'توصيل') return 0;

    final addressState = context.read<AddressBloc>().state;
    final businessState = context.read<BusinessBloc>().state;

    if (addressState is! AddressLoaded) return 0;
    if (businessState is! BusinessFetched) return 0;

    AddressEntity? defaultAddress;

    for (final address in addressState.addresses) {
      if (address.isDefault) {
        defaultAddress = address;
        break;
      }
    }

    if (defaultAddress == null) return 0;

    for (final business in businessState.businesses) {
      if (business.id == businessId) {
        final distanceKm = DistanceUtils.calculateDistanceKm(
          customerLatitude: defaultAddress.latitude,
          customerLongitude: defaultAddress.longitude,
          restaurantLatitude: business.latitude,
          restaurantLongitude: business.longitude,
        );

        return DeliveryPriceUtils.calculateDeliveryPrice(distanceKm) ?? 0;
      }
    }

    return 0;
  }

  // ============================================================
  // DEFAULT DELIVERY ADDRESS (source of truth)
  // ============================================================
  //
  // BUGFIX: previously the order's stored deliveryAddress text used
  // profile.address, while _calculateDeliveryPrice above used
  // AddressBloc's *default* address for the fee -- two different
  // addresses could silently disagree. Both the text and the new
  // lat/lng columns now come from this single source.
  // ============================================================

  AddressEntity? _defaultAddress(BuildContext context) {
    final addressState = context.read<AddressBloc>().state;
    if (addressState is! AddressLoaded) return null;

    for (final address in addressState.addresses) {
      if (address.isDefault) return address;
    }
    return null;
  }

  Future<void> _onConfirm() async {
    final orderState = context.read<OrderBloc>().state;
    if (orderState is OrderPlacing) return;

    final cartState = context.read<CartBloc>().state;
    final profileState = context.read<ProfileBloc>().state;

    if (cartState.items.isEmpty ||
        profileState is! ProfileLoaded ||
        cartState.businessId == null) {
      return;
    }

    if (selectedOrderType == 'طلب مسبق' && _scheduledFor == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اختر وقت الجدولة أولاً')));
      return;
    }
    if (_blockIfRestaurantNowClosed(context, cartState.businessId!)) {
      return;
    }

    final profile = profileState.profile;

    // BUGFIX: total_price previously only included item subtotal —
    // delivery fee was never added, meaning every stored order
    // undercharged the actual amount the restaurant should collect
    // (this app is cash-only, so this directly affects real money
    // changing hands).
    final deliveryPrice = _calculateDeliveryPrice(
      context,
      cartState.businessId!,
    );

    final totalPrice = cartState.totalPrice + deliveryPrice;

    final isDelivery = selectedDeliveryOption == 'توصيل';
    final defaultAddress = _defaultAddress(context);

   final order = OrderEntity(
  businessId: cartState.businessId!,
  customerId: profile.id,
  customername: profile.userName,
  customerPhone: profile.phoneNumber,
  items: cartState.items,
  deliveryAddress: isDelivery
    ? (defaultAddress != null
        ? '${defaultAddress.street}, ${defaultAddress.city}, ${defaultAddress.apartment}'
        : profile.address)
    : null,
  deliveryLatitude: isDelivery ? defaultAddress?.latitude : null,
  deliveryLongitude: isDelivery ? defaultAddress?.longitude : null,
  totalPrice: totalPrice,
  deliveryFee: deliveryPrice, // <-- ADD THIS
  orderType: isDelivery ? OrderType.delivery : OrderType.pickup,
  orderStatus: OrderStatus.pending,
  scheduledFor: selectedOrderType == 'طلب مسبق' ? _scheduledFor : null,
  description: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
  businessName: cartState.businessName,
  businessLogo: cartState.businessLogo,
);

    // ================================================================
    // COUNTDOWN CONFIRMATION
    // ================================================================
    //
    // Order is NOT placed yet — this shows a 5s countdown with a cancel
    // button. Only if it resolves to `true` (timer ran out naturally,
    // customer didn't cancel) do we actually dispatch PlaceOrderEvent.
    // ================================================================

    final shouldPlaceOrder = await OrderCountdownDialog.show(context);

    if (shouldPlaceOrder != true) return;

    if (!mounted) return;

    context.read<OrderBloc>().add(PlaceOrderEvent(order: order));
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
                context.go('/order-placed');
              }
              if (state is OrderError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckoutAppBar(onBackTap: () => Navigator.pop(context)),
                  const SizedBox(height: AppSpacing.lg),
                  DeliveryOptionSection(
                    selectedOption: selectedDeliveryOption,
                    onOptionChanged: (v) =>
                        setState(() => selectedDeliveryOption = v),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OrderTypeSection(
                    selectedOption: selectedOrderType,
                    onOptionChanged: (v) {
                      setState(() => selectedOrderType = v);
                      if (v == 'طلب مسبق') _pickScheduleTime();
                    },
                  ),
                  if (selectedOrderType == 'طلب مسبق' &&
                      _scheduledFor != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: AppSizes.iconSm,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'موعد الجدولة: ${TimeOfDay.fromDateTime(_scheduledFor!).format(context)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _pickScheduleTime,
                            child: const Text('تغيير'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),

                  // 📝 Notes Field Container
                  Text('ملاحظات إضافية', style: AppTextStyles.regularLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 3,
                      style: AppTextStyles.regularMedium,
                      decoration: InputDecoration(
                        hintText:
                            'اكتب أي ملاحظات للطلب (مثال: لا ترن الجرس ...)',
                        hintStyle: AppTextStyles.regularSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  BlocBuilder<OrderBloc, OrderState>(
                    builder: (context, state) {
                      return ConfirmButton(
                        onConfirm: state is OrderPlacing ? () {} : _onConfirm,
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