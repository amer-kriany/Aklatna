import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';
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

  void _onConfirm() {
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

    final profile = profileState.profile;

    final order = OrderEntity(
      businessId: cartState.businessId!,
      customerId: profile.id,
      customername: profile.userName,
      customerPhone: profile.phoneNumber,
      items: cartState.items,
      deliveryAddress: selectedDeliveryOption == 'توصيل'
          ? profile.address
          : null,
      totalPrice: cartState.totalPrice,
      orderType: selectedDeliveryOption == 'توصيل'
          ? OrderType.delivery
          : OrderType.pickup,
      orderStatus: OrderStatus.pending,
      scheduledFor: selectedOrderType == 'طلب مسبق' ? _scheduledFor : null,
      description: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

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
