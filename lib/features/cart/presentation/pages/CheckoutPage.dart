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

  // IMPORTANT:
  // This always contains the selected time in the user's LOCAL timezone.
  // We convert it to UTC only when sending the order to Supabase.
  DateTime? _scheduledFor;

  final TextEditingController _notesController =
      TextEditingController();

  // ============================================================
  // RESTAURANT OPEN/CLOSED CHECK
  // ============================================================

  bool _blockIfRestaurantNowClosed(
    BuildContext context,
    String businessId,
  ) {
    final businessState = context.read<BusinessBloc>().state;

    if (businessState is! BusinessFetched) {
      return false;
    }

    for (final business in businessState.businesses) {
      if (business.id == businessId) {
        if (!business.isOpen) {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppRadius.lg),
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
                      borderRadius:
                          BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  onPressed: () =>
                      Navigator.pop(dialogContext),
                  child: Text(
                    'حسناً',
                    style:
                        AppTextStyles.buttonMedium.copyWith(
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

  // ============================================================
  // ACTIVE ORDER CHECK
  // ============================================================
  //
  // IMPORTANT:
  //
  // A normal pending order = active.
  //
  // A scheduled pending order whose time is still in the future
  // = NOT active yet.
  //
  // preparing / ready / out_for_delivery = always active.
  //
  // This prevents a future scheduled order from appearing as
  // the customer's ongoing order.
  // ============================================================

  bool _hasActiveOrder(BuildContext context) {
    final orderState = context.read<OrderBloc>().state;

    if (orderState is! CustomerOrdersFetched) {
      return false;
    }

    final nowUtc = DateTime.now().toUtc();

    return orderState.orders.any((order) {
      // --------------------------------------------------------
      // PREPARING / READY / OUT FOR DELIVERY
      // --------------------------------------------------------

      if (order.orderStatus == OrderStatus.preparing ||
          order.orderStatus == OrderStatus.ready ||
          order.orderStatus == OrderStatus.outForDelivery) {
        return true;
      }

      // --------------------------------------------------------
      // PENDING
      // --------------------------------------------------------

      if (order.orderStatus == OrderStatus.pending) {
        // Normal pending order = active.
        if (order.scheduledFor == null) {
          return true;
        }

        // Scheduled pending order:
        //
        // If its scheduled time has NOT arrived yet,
        // it is NOT an active ongoing order.
        //
        // If the scheduled time has arrived,
        // it becomes active.
        final scheduledUtc =
            order.scheduledFor!.toUtc();

        return !scheduledUtc.isAfter(nowUtc);
      }

      return false;
    });
  }

  // ============================================================
  // ACTIVE ORDER DIALOG
  // ============================================================

  void _showActiveOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppRadius.lg),
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
                borderRadius:
                    BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: () =>
                Navigator.pop(dialogContext),
            child: Text(
              'حسناً',
              style:
                  AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK SCHEDULE TIME
  // ============================================================

  Future<void> _pickScheduleTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) {
      return;
    }

    final now = DateTime.now();

    // Create the selected time in LOCAL timezone.
    final localScheduled = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );

    DateTime scheduled = localScheduled;

    // If the selected time already passed today,
    // treat it as tomorrow.
    if (scheduled.isBefore(now)) {
      scheduled =
          scheduled.add(const Duration(days: 1));
    }

    setState(() {
      _scheduledFor = scheduled;
    });
  }

  // ============================================================
  // DELIVERY PRICE CALC
  // ============================================================

  double _calculateDeliveryPrice(
    BuildContext context,
    String businessId,
  ) {
    if (selectedDeliveryOption != 'توصيل') {
      return 0;
    }

    final addressState =
        context.read<AddressBloc>().state;

    final businessState =
        context.read<BusinessBloc>().state;

    if (addressState is! AddressLoaded) {
      return 0;
    }

    if (businessState is! BusinessFetched) {
      return 0;
    }

    AddressEntity? defaultAddress;

    for (final address in addressState.addresses) {
      if (address.isDefault) {
        defaultAddress = address;
        break;
      }
    }

    if (defaultAddress == null) {
      return 0;
    }

    for (final business in businessState.businesses) {
      if (business.id == businessId) {
        final distanceKm =
            DistanceUtils.calculateDistanceKm(
          customerLatitude:
              defaultAddress.latitude,
          customerLongitude:
              defaultAddress.longitude,
          restaurantLatitude:
              business.latitude,
          restaurantLongitude:
              business.longitude,
        );

        return DeliveryPriceUtils
                .calculateDeliveryPrice(distanceKm) ??
            0;
      }
    }

    return 0;
  }

  // ============================================================
  // DEFAULT DELIVERY ADDRESS
  // ============================================================

  AddressEntity? _defaultAddress(
    BuildContext context,
  ) {
    final addressState =
        context.read<AddressBloc>().state;

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

  // ============================================================
  // CONFIRM ORDER
  // ============================================================

  Future<void> _onConfirm() async {
    final orderState =
        context.read<OrderBloc>().state;

    if (orderState is OrderPlacing) {
      return;
    }

    // ----------------------------------------------------------
    // CHECK ACTIVE ORDER
    // ----------------------------------------------------------

    if (_hasActiveOrder(context)) {
      _showActiveOrderDialog(context);
      return;
    }

    // ----------------------------------------------------------
    // GET STATES
    // ----------------------------------------------------------

    final cartState =
        context.read<CartBloc>().state;

    final profileState =
        context.read<ProfileBloc>().state;

    if (cartState.items.isEmpty ||
        profileState is! ProfileLoaded ||
        cartState.businessId == null) {
      return;
    }

    // ----------------------------------------------------------
    // SCHEDULE VALIDATION
    // ----------------------------------------------------------

    if (selectedOrderType == 'طلب مسبق' &&
        _scheduledFor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'اختر وقت الجدولة أولاً',
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // RESTAURANT OPEN CHECK
    // ----------------------------------------------------------

    if (_blockIfRestaurantNowClosed(
      context,
      cartState.businessId!,
    )) {
      return;
    }

    // ----------------------------------------------------------
    // PROFILE
    // ----------------------------------------------------------

    final profile = profileState.profile;

    // ----------------------------------------------------------
    // DELIVERY
    // ----------------------------------------------------------

    final deliveryPrice =
        _calculateDeliveryPrice(
      context,
      cartState.businessId!,
    );

    final totalPrice =
        cartState.totalPrice + deliveryPrice;

    final isDelivery =
        selectedDeliveryOption == 'توصيل';

    final defaultAddress =
        _defaultAddress(context);

    // ----------------------------------------------------------
    // SCHEDULED TIME
    // ----------------------------------------------------------
    //
    // _scheduledFor is LOCAL.
    //
    // Supabase/PostgreSQL stores timestamptz in UTC.
    //
    // Therefore:
    //
    // LOCAL -> UTC
    //
    // Example:
    //
    // 22:40 local
    //       ↓
    // 19:40 UTC
    //
    // This is critical for the 30-minute cron check.
    // ----------------------------------------------------------

    final DateTime? scheduledForUtc =
        selectedOrderType == 'طلب مسبق'
            ? _scheduledFor?.toUtc()
            : null;

    // ----------------------------------------------------------
    // CREATE ORDER
    // ----------------------------------------------------------

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

      deliveryLatitude:
          isDelivery
              ? defaultAddress?.latitude
              : null,

      deliveryLongitude:
          isDelivery
              ? defaultAddress?.longitude
              : null,

      totalPrice: totalPrice,
      deliveryFee: deliveryPrice,

      orderType:
          isDelivery
              ? OrderType.delivery
              : OrderType.pickup,

      orderStatus: OrderStatus.pending,

      // IMPORTANT:
      // Send UTC to Supabase.
      scheduledFor: scheduledForUtc,

      description:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),

      businessName:
          cartState.businessName,

      businessLogo:
          cartState.businessLogo,
    );

    // ----------------------------------------------------------
    // COUNTDOWN CONFIRMATION
    // ----------------------------------------------------------

    final shouldPlaceOrder =
        await OrderCountdownDialog.show(
      context,
    );

    if (shouldPlaceOrder != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // PLACE ORDER
    // ----------------------------------------------------------

    context.read<OrderBloc>().add(
          PlaceOrderEvent(
            order: order,
            customerId: profile.id,
          ),
        );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            AppColors.background,
        body: SafeArea(
          child: BlocListener<OrderBloc, OrderState>(
            listener: (context, state) {
              // ------------------------------------------------
              // ORDER PLACED
              // ------------------------------------------------

              if (state is OrderPlaced) {
                context
                    .read<CartBloc>()
                    .add(
                      ClearCartEvent(),
                    );

                context.go('/order-placed');
              }

              // ------------------------------------------------
              // ERROR
              // ------------------------------------------------

              if (state is OrderError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(
                    content:
                        Text(state.message),
                  ),
                );
              }
            },

            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(
                horizontal:
                    AppSpacing.lg,
                vertical:
                    AppSpacing.md,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ------------------------------------------------
                  // APP BAR
                  // ------------------------------------------------

                  CheckoutAppBar(
                    onBackTap:
                        () => Navigator.pop(
                      context,
                    ),
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  // ------------------------------------------------
                  // DELIVERY / PICKUP
                  // ------------------------------------------------

                  DeliveryOptionSection(
                    selectedOption:
                        selectedDeliveryOption,
                    onOptionChanged: (value) {
                      setState(() {
                        selectedDeliveryOption =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  // ------------------------------------------------
                  // ORDER TYPE
                  // ------------------------------------------------

                  OrderTypeSection(
                    selectedOption:
                        selectedOrderType,
                    onOptionChanged: (value) {
                      setState(() {
                        selectedOrderType =
                            value;
                      });

                      if (value ==
                          'طلب مسبق') {
                        _pickScheduleTime();
                      } else {
                        // Clear scheduled time when switching
                        // back to normal order.
                        setState(() {
                          _scheduledFor = null;
                        });
                      }
                    },
                  ),

                  // ------------------------------------------------
                  // SCHEDULED TIME
                  // ------------------------------------------------

                  if (selectedOrderType ==
                          'طلب مسبق' &&
                      _scheduledFor != null) ...[
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            AppSpacing.xs,
                      ),

                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size:
                                AppSizes.iconSm,
                            color:
                                AppColors.primary,
                          ),

                          const SizedBox(
                            width:
                                AppSpacing.xs,
                          ),

                          Text(
                            'موعد الجدولة: '
                            '${TimeOfDay.fromDateTime(
                              _scheduledFor!,
                            ).format(context)}',
                            style: AppTextStyles
                                .bodyMedium
                                .copyWith(
                              color:
                                  AppColors.primary,
                            ),
                          ),

                          const Spacer(),

                          TextButton(
                            onPressed:
                                _pickScheduleTime,
                            child:
                                const Text(
                              'تغيير',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(
                    height:
                        AppSpacing.xl,
                  ),

                  // ------------------------------------------------
                  // NOTES
                  // ------------------------------------------------

                  Text(
                    'ملاحظات إضافية',
                    style:
                        AppTextStyles.regularLarge,
                  ),

                  const SizedBox(
                    height:
                        AppSpacing.xs,
                  ),

                  Container(
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(
                        AppRadius.md,
                      ),
                      border:
                          Border.all(
                        color:
                            AppColors.border,
                      ),
                    ),

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal:
                          AppSpacing.md,
                      vertical:
                          AppSpacing.xs,
                    ),

                    child: TextField(
                      controller:
                          _notesController,
                      maxLines: 3,
                      style:
                          AppTextStyles.regularMedium,

                      decoration:
                          InputDecoration(
                        hintText:
                            'اكتب أي ملاحظات للطلب '
                            '(مثال: لا ترن الجرس ...)',

                        hintStyle:
                            AppTextStyles
                                .regularSmall
                                .copyWith(
                          color:
                              AppColors
                                  .textSecondary,
                        ),

                        border:
                            InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                        AppSpacing.xxl,
                  ),

                  // ------------------------------------------------
                  // CONFIRM BUTTON
                  // ------------------------------------------------

                  BlocBuilder<OrderBloc, OrderState>(
                    builder:
                        (context, state) {
                      return ConfirmButton(
                        onConfirm:
                            state is OrderPlacing
                                ? () {}
                                : _onConfirm,
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