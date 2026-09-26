import 'package:aklatna/features/cart/presentation/bloc/cart_state.dart';
import 'package:aklatna/features/cart/presentation/widgets/checkout/orderCountDownDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';
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

  // ===========================================================================
  // RESTAURANT OPEN / CLOSED
  // ===========================================================================

  bool _blockIfRestaurantNowClosed(BuildContext context, String businessId) {
    final businessState = context.read<BusinessBloc>().state;

    if (businessState is! BusinessFetched) {
      return false;
    }

    for (final business in businessState.businesses) {
      if (business.id == businessId) {
        if (!business.isOpen) {
          showDialog(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                title: Text(
                  'المطعم مغلق الآن',
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  'المطعم مغلق حالياً ولا يمكن إتمام الطلب. يمكنك المحاولة لاحقاً.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
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
              );
            },
          );

          return true;
        }

        break;
      }
    }

    return false;
  }

  // ===========================================================================
  // ACTIVE ORDER
  // ===========================================================================

  bool _hasActiveOrder(BuildContext context) {
    final orderState = context.read<OrderBloc>().state;

    if (orderState is! CustomerOrdersFetched) {
      return false;
    }

    final nowUtc = DateTime.now().toUtc();

    return orderState.orders.any((order) {
      if (order.orderStatus == OrderStatus.preparing ||
          order.orderStatus == OrderStatus.ready ||
          order.orderStatus == OrderStatus.outForDelivery) {
        return true;
      }

      if (order.orderStatus == OrderStatus.pending) {
        if (order.scheduledFor == null) {
          return true;
        }

        final scheduledUtc = order.scheduledFor!.toUtc();

        return !scheduledUtc.isAfter(nowUtc);
      }

      return false;
    });
  }

  // ===========================================================================
  // ACTIVE ORDER DIALOG
  // ===========================================================================

  void _showActiveOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delivery_dining_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'لديك طلب قيد التنفيذ',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
            ],
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
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'حسناً',
                style: AppTextStyles.buttonMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // SCHEDULE
  // ===========================================================================

  Future<void> _pickScheduleTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) {
      return;
    }

    final now = DateTime.now();

    final localScheduled = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );

    DateTime scheduled = localScheduled;

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    if (!mounted) return;

    setState(() {
      _scheduledFor = scheduled;
    });
  }

  // ===========================================================================
  // DEFAULT ADDRESS
  // ===========================================================================

  AddressEntity? _defaultAddress(BuildContext context) {
    final addressState = context.read<AddressBloc>().state;

    if (addressState is! AddressLoaded) {
      return null;
    }

    for (final address in addressState.addresses) {
      if (address.isDefault) {
        return address;
      }
    }

    return null;
  }

  // ===========================================================================
  // CONFIRM ORDER
  // ===========================================================================

  Future<void> _onConfirm() async {
    final orderState = context.read<OrderBloc>().state;

    if (orderState is OrderPlacing) {
      return;
    }

    if (_hasActiveOrder(context)) {
      _showActiveOrderDialog(context);
      return;
    }

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

    final totalPrice = cartState.totalPrice;

    final isDelivery = selectedDeliveryOption == 'توصيل';

    final defaultAddress = _defaultAddress(context);

    final DateTime? scheduledForUtc = selectedOrderType == 'طلب مسبق'
        ? _scheduledFor?.toUtc()
        : null;

    final order = OrderEntity(
      businessId: cartState.businessId!,
      customerId: profile.id,
      customername: profile.userName,
      customerPhone: profile.phoneNumber,
      items: cartState.items,

      deliveryAddress: isDelivery
          ? (defaultAddress != null
                ? '${defaultAddress.street}, '
                      '${defaultAddress.city}, '
                      '${defaultAddress.apartment}'
                : profile.address)
          : null,

      deliveryLatitude: isDelivery ? defaultAddress?.latitude : null,

      deliveryLongitude: isDelivery ? defaultAddress?.longitude : null,

      totalPrice: totalPrice,

      orderType: isDelivery ? OrderType.delivery : OrderType.pickup,

      orderStatus: OrderStatus.pending,

      scheduledFor: scheduledForUtc,

      description: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),

      businessName: cartState.businessName,

      businessLogo: cartState.businessLogo,
    );

    final shouldPlaceOrder = await OrderCountdownDialog.show(context);

    if (shouldPlaceOrder != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    context.read<OrderBloc>().add(
      PlaceOrderEvent(order: order, customerId: profile.id),
    );
  }

  // ===========================================================================
  // FORMAT PRICE
  // ===========================================================================

  String _formatPrice(double value) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  // ===========================================================================
  // SECTION TITLE
  // ===========================================================================

  Widget _sectionTitle({
    required String title,
    String? subtitle,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null)
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),

        if (icon != null) const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.regularLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.regularSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // DELIVERY INFO
  // ===========================================================================

  Widget _buildDeliveryInfo(BuildContext context) {
    final address = _defaultAddress(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border.withOpacity(0.65)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عنوان التوصيل',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  address != null
                      ? '${address.street}, ${address.city}'
                      : 'العنوان الافتراضي',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SCHEDULE CARD
  // ===========================================================================

  Widget _buildScheduleCard() {
    if (selectedOrderType != 'طلب مسبق' || _scheduledFor == null) {
      return const SizedBox.shrink();
    }

    final time = TimeOfDay.fromDateTime(_scheduledFor!);

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: AppColors.primary,
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'موعد الطلب',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time.format(context),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          TextButton(onPressed: _pickScheduleTime, child: const Text('تغيير')),
        ],
      ),
    );
  }

  // ===========================================================================
  // NOTES
  // ===========================================================================

  Widget _buildNotes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                'ملاحظات الطلب',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: 6),

              Text(
                'اختياري',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          TextField(
            controller: _notesController,
            maxLines: 4,
            minLines: 3,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: AppTextStyles.regularMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'مثال: لا ترن الجرس، بدون بصل...',
              hintStyle: AppTextStyles.regularSmall.copyWith(
                color: AppColors.textSecondary.withOpacity(0.8),
                height: 1.5,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ORDER SUMMARY
  // ===========================================================================

  Widget _buildOrderSummary(CartState cartState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 19,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'ملخص الطلب',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Text(
                '${cartState.items.length} عناصر',
                style: AppTextStyles.regularSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${_formatPrice(cartState.totalPrice)} ل.س',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Divider(color: AppColors.border.withOpacity(0.6), height: 1),

          if (selectedDeliveryOption == 'توصيل') ...[
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.delivery_dining_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رسوم التوصيل',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'يتم الاتفاق عليها بشكل منفصل مع سائق التوصيل',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  'غير محسوبة',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Divider(color: AppColors.border.withOpacity(0.6), height: 1),
          ],

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                'الإجمالي',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_formatPrice(cartState.totalPrice)} ل.س',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '+ رسوم التوصيل',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
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

            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.xxl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckoutAppBar(
                              onBackTap: () => Navigator.pop(context),
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // =================================================
                            // INTRO
                            // =================================================
                            Text(
                              'جاهز لتأكيد طلبك؟',
                              style: AppTextStyles.h2.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'اختر طريقة الاستلام والوقت المناسب لك.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // =================================================
                            // DELIVERY
                            // =================================================
                            _sectionTitle(
                              title: 'طريقة الاستلام',
                              subtitle: 'كيف تريد استلام طلبك؟',
                              icon: Icons.near_me_rounded,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            DeliveryOptionSection(
                              selectedOption: selectedDeliveryOption,
                              onOptionChanged: (value) {
                                setState(() {
                                  selectedDeliveryOption = value;
                                });
                              },
                            ),

                            if (selectedDeliveryOption == 'توصيل')
                              _buildDeliveryInfo(context),

                            const SizedBox(height: AppSpacing.xl),

                            // =================================================
                            // ORDER TYPE
                            // =================================================
                            _sectionTitle(
                              title: 'وقت الطلب',
                              subtitle: 'اختر متى تريد تجهيز طلبك',
                              icon: Icons.access_time_rounded,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            OrderTypeSection(
                              selectedOption: selectedOrderType,
                              onOptionChanged: (value) {
                                setState(() {
                                  selectedOrderType = value;
                                });

                                if (value == 'طلب مسبق') {
                                  _pickScheduleTime();
                                } else {
                                  setState(() {
                                    _scheduledFor = null;
                                  });
                                }
                              },
                            ),

                            _buildScheduleCard(),

                            const SizedBox(height: AppSpacing.xl),

                            // =================================================
                            // NOTES
                            // =================================================
                            _buildNotes(),

                            const SizedBox(height: AppSpacing.xl),

                            // =================================================
                            // SUMMARY
                            // =================================================
                            _sectionTitle(
                              title: 'ملخص الطلب',
                              icon: Icons.receipt_long_rounded,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            _buildOrderSummary(cartState),
                          ],
                        ),
                      ),
                    ),

                    // ===========================================================
                    // BOTTOM CONFIRMATION
                    // ===========================================================
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 18,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            12,
                            AppSpacing.lg,
                            AppSpacing.md,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: BlocBuilder<OrderBloc, OrderState>(
                              builder: (context, state) {
                                return ConfirmButton(
                                  onConfirm: state is OrderPlacing
                                      ? () {}
                                      : _onConfirm,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
