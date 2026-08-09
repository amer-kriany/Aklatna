import 'dart:async';

import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/domain/usecases/accept_order_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/complete_order_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/getDriverOrdersUseCase.dart';
import 'package:aklatna/features/orders/domain/usecases/get_available_orders_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/get_customer_orders_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/mark_out_for_delivery_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/orderStatusUseCase.dart';
import 'package:aklatna/features/orders/domain/usecases/place_order_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/watchAvailableOrderUsecase.dart';
import 'package:aklatna/features/orders/domain/usecases/watchDriverOrder.dart';
import 'package:aklatna/features/orders/orderStatus.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final Orderstatususecase watchOrderStatusUsecase;
  final PlaceOrderUsecase placeOrderUsecase;
  final GetAvailableOrdersUseCase getAvailableOrdersUseCase;
  final AcceptOrderUseCase acceptOrderUseCase;
  final MarkOutForDeliveryUseCase markOutForDeliveryUseCase;
  final CompleteOrderUseCase completeOrderUseCase;
  final GetDriverOrdersUseCase getDriverOrdersUseCase;
  final WatchAvailableOrdersUseCase watchAvailableOrdersUseCase;
  final WatchDriverOrdersUseCase watchDriverOrdersUseCase;
  final GetCustomerOrdersUseCase customerOrdersUsecase;

  StreamSubscription<OrderEntity>? _orderStatusSubscription;
  StreamSubscription<void>? _availableOrdersRealtimeSubscription;
  StreamSubscription<void>? _driverOrdersRealtimeSubscription;

  // --------------------------------------------------------------
  // Keeps the last known orders list around even while state is
  // OrderLoading/OrderPlaced, so _placeOrder can still check for
  // an active order without depending on `state` being
  // CustomerOrdersFetched at that exact moment.
  // --------------------------------------------------------------
  List<OrderEntity> _lastKnownOrders = [];

  OrderBloc({
    required this.placeOrderUsecase,
    required this.customerOrdersUsecase,
    required this.watchOrderStatusUsecase,
    required this.getAvailableOrdersUseCase,
    required this.acceptOrderUseCase,
    required this.markOutForDeliveryUseCase,
    required this.completeOrderUseCase,
    required this.getDriverOrdersUseCase,
    required this.watchAvailableOrdersUseCase,
    required this.watchDriverOrdersUseCase,
  }) : super(OrderInitial()) {
    on<PlaceOrderEvent>(_placeOrder);
    on<GetCustomerOrdersEvent>(_getCustomerOrders);
    on<WatchOrderStatusEvent>(_watchOrderStatus);
    on<GetAvailableOrdersEvent>(_getAvailableOrders);
    on<AcceptOrderEvent>(_acceptOrder);
    on<MarkOutForDeliveryEvent>(_markOutForDelivery);
    on<CompleteOrderEvent>(_completeOrder);
    on<GetDriverOrdersEvent>(_getDriverOrders);

    on<_OrderRealtimeUpdatedEvent>(_updateOrderInState);
    on<_OrderRealtimeErrorEvent>(_handleRealtimeError);
  }

  // ============================================================
  // PLACE ORDER
  // ============================================================

  Future<void> _placeOrder(
    PlaceOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    // ----------------------------------------------------------
    // Bloc-level safety net: block a second active order even if
    // the UI guard (CartCheckoutButton) somehow got bypassed or
    // was working off stale state.
    // ----------------------------------------------------------
    final hasActiveOrder = _lastKnownOrders.any(_isOngoing);

    if (hasActiveOrder) {
      emit(
        const OrderError(
          message:
              'لديك طلب قيد التنفيذ حالياً، لا يمكنك إنشاء طلب جديد حتى يكتمل أو يُلغى',
        ),
      );
      return;
    }

    emit(OrderLoading());

    try {
      await placeOrderUsecase(event.order);

      emit(OrderPlaced());
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }

  // ============================================================
  // GET CUSTOMER ORDERS
  // ============================================================

  Future<void> _getCustomerOrders(
    GetCustomerOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      final orders = await customerOrdersUsecase(event.customerId);

      _lastKnownOrders = orders;

      emit(CustomerOrdersFetched(orders: orders));

      // --------------------------------------------------------
      // Find the currently ongoing order
      // --------------------------------------------------------

      final ongoingOrders = orders.where(_isOngoing).toList();

      // --------------------------------------------------------
      // Watch the first ongoing order
      // --------------------------------------------------------

      if (ongoingOrders.isNotEmpty) {
        final ongoingOrder = ongoingOrders.first;

        if (ongoingOrder.id != null) {
          add(WatchOrderStatusEvent(orderId: ongoingOrder.id!));
        }
      }
    } catch (e) {
      emit(OrderFailure(error: e.toString()));
    }
  }

  // ============================================================
  // REALTIME ORDER STATUS
  // ============================================================

  Future<void> _watchOrderStatus(
    WatchOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    // Cancel previous subscription
    await _orderStatusSubscription?.cancel();

    _orderStatusSubscription = watchOrderStatusUsecase(event.orderId).listen(
      (updatedOrder) {
        add(_OrderRealtimeUpdatedEvent(order: updatedOrder));
      },
      onError: (error) {
        add(const _OrderRealtimeErrorEvent());
      },
    );
  }

  // ============================================================
  // REALTIME UPDATE EVENT
  // ============================================================

  void _updateOrderInState(
    _OrderRealtimeUpdatedEvent event,
    Emitter<OrderState> emit,
  ) {
    final currentState = state;

    // Find the previous version of this order.
    final previousOrder = _lastKnownOrders.cast<OrderEntity?>().firstWhere(
      (order) => order?.id == event.order.id,
      orElse: () => null,
    );

    final wasCompleted = previousOrder?.orderStatus == OrderStatus.completed;

    final isNowCompleted = event.order.orderStatus == OrderStatus.completed;

    // TRUE only when the order actually transitions into completed.
    final justCompleted = !wasCompleted && isNowCompleted;

    // ----------------------------------------------------------
    // Update stored orders
    // ----------------------------------------------------------

    final updatedOrders = _lastKnownOrders.map((order) {
      if (order.id == event.order.id) {
        return event.order;
      }

      return order;
    }).toList();

    _lastKnownOrders = updatedOrders;

    // ----------------------------------------------------------
    // Keep CustomerOrdersFetched working normally
    // ----------------------------------------------------------

    if (currentState is CustomerOrdersFetched) {
      final stateOrders = currentState.orders.map((order) {
        if (order.id == event.order.id) {
          return event.order;
        }

        return order;
      }).toList();

      emit(CustomerOrdersFetched(orders: stateOrders));
    }

    // ----------------------------------------------------------
    // The order JUST became completed
    // ----------------------------------------------------------

    if (justCompleted) {
      emit(OrderJustCompleted(order: event.order));
    }

    // ----------------------------------------------------------
    // Stop watching finished order
    // ----------------------------------------------------------

    if (!_isOngoing(event.order)) {
      _orderStatusSubscription?.cancel();
      _orderStatusSubscription = null;
    }
  }

  // ============================================================
  // REALTIME ERROR
  // ============================================================

  void _handleRealtimeError(
    _OrderRealtimeErrorEvent event,
    Emitter<OrderState> emit,
  ) {
    // Don't destroy the existing orders state.
    //
    // The user can still see the last known status.
    //
    // We intentionally don't emit OrderStatusError here because
    // that would replace CustomerOrdersFetched and hide the list.
  }

  // ============================================================
  // ONGOING CHECK
  // ============================================================
  //
  // FIXED: previously grouped `completed` with pending/preparing/
  // ready under the same `return true`, which meant a completed
  // order stayed on the homepage as "ongoing" forever and kept
  // blocking the customer from placing their next order.
  // Per the locked rule: only pending/preparing/ready are ongoing.
  // ============================================================

  bool _isOngoing(OrderEntity order) => order.orderStatus.isOngoing;
  // ============================================================
  // DRIVER - AVAILABLE ORDERS
  // ============================================================

  Future<void> _getAvailableOrders(
    GetAvailableOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      final orders = await getAvailableOrdersUseCase();

      // Earnings shown on the driver home page -- fetched alongside the
      // available list rather than a separate query round trip. Only
      // completed deliveries count; cancelled never paid out.
      final driverOrders = await getDriverOrdersUseCase(event.driverId);
      final totalEarnings = driverOrders
          .where((o) => o.orderStatus == OrderStatus.completed)
          .fold<double>(0, (sum, o) => sum + o.deliveryFee);

      final hasActiveDelivery = driverOrders.any(
        (o) => o.orderStatus.isOngoing,
      );

      emit(
        AvailableOrdersLoaded(
          orders: orders,
          totalEarnings: totalEarnings,
          hasActiveDelivery: hasActiveDelivery,
        ),
      );

      // Start once, keep listening across refetches of this same
      // handler -- any change to a delivery order (new pending order,
      // another driver claiming one, etc.) re-triggers a fresh fetch.
      _availableOrdersRealtimeSubscription ??= watchAvailableOrdersUseCase()
          .listen((_) {
            // Guard: this fires on ANY delivery-order change, including
            // ones triggered from other screens (e.g. marking an order
            // out-for-delivery from "توصيلاتي"). Without this check it
            // would overwrite DriverOrdersFetched with a stale
            // AvailableOrdersLoaded right after, making the other screen
            // go blank until the user navigates away and back.
            if (state is AvailableOrdersLoaded) {
              add(GetAvailableOrdersEvent(driverId: event.driverId));
            }
          });
    } catch (e) {
      emit(OrderFailure(error: e.toString()));
    }
  }

  // ============================================================
  // DRIVER - ACCEPT ORDER
  // ============================================================

  Future<void> _acceptOrder(
    AcceptOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await acceptOrderUseCase(
        orderId: event.orderId,
        driverId: event.driverId,
      );

      // BUGFIX: `state` here is checked fresh, not against the
      // `preAcceptState` snapshot taken before the await above. This
      // handler can take a while (network call), and the UI often
      // navigates away during that gap (e.g. straight to "توصيلاتي"
      // after tapping accept) -- another event can legitimately change
      // the bloc's live state in the meantime. Emitting based on a
      // stale snapshot here previously stomped whatever screen the
      // driver had already navigated to back to a leftover
      // AvailableOrdersLoaded, making it go blank.
      if (state is AvailableOrdersLoaded) {
        final liveState = state as AvailableOrdersLoaded;
        emit(
          AvailableOrdersLoaded(
            orders: liveState.orders
                .where((o) => o.id != event.orderId)
                .toList(),
            totalEarnings: liveState.totalEarnings,
            hasActiveDelivery: true,
          ),
        );
      }

      add(WatchOrderStatusEvent(orderId: event.orderId));
    } catch (e) {
      // Someone else claimed it first (RLS blocked us) or a network
      // error — either way, drop just this order from the list rather
      // than replacing the whole screen with an error state. Same
      // live-state fix as above.
      if (state is AvailableOrdersLoaded) {
        final liveState = state as AvailableOrdersLoaded;
        emit(
          AvailableOrdersLoaded(
            orders: liveState.orders
                .where((o) => o.id != event.orderId)
                .toList(),
            totalEarnings: liveState.totalEarnings,
            hasActiveDelivery: liveState.hasActiveDelivery,
          ),
        );
      }
    }
  }

  // ============================================================
  // DRIVER - OUT FOR DELIVERY
  // ============================================================

  Future<void> _markOutForDelivery(
    MarkOutForDeliveryEvent event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await markOutForDeliveryUseCase(orderId: event.orderId);

      add(GetDriverOrdersEvent(driverId: event.driverId));
    } catch (e) {
      emit(OrderFailure(error: e.toString()));
    }
  }

  // ============================================================
  // DRIVER - MY DELIVERIES
  // ============================================================

  Future<void> _getDriverOrders(
    GetDriverOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      final orders = await getDriverOrdersUseCase(event.driverId);

      emit(DriverOrdersFetched(orders: orders));

      // Picks up status changes made from outside this driver's own
      // taps -- e.g. the restaurant moving preparing -> ready via their
      // dashboard/Studio while the driver is sitting on "توصيلاتي".
      // Guarded the same way as the available-orders subscription: only
      // refetch while this screen's state is actually the current one,
      // so it can't clobber AvailableOrdersLoaded if the driver has
      // since switched tabs.
      _driverOrdersRealtimeSubscription ??=
          watchDriverOrdersUseCase(event.driverId).listen((_) {
            if (state is DriverOrdersFetched) {
              add(GetDriverOrdersEvent(driverId: event.driverId));
            }
          });
    } catch (e) {
      emit(OrderFailure(error: e.toString()));
    }
  }

  // ============================================================
  // DRIVER - COMPLETE ORDER
  // ============================================================

  Future<void> _completeOrder(
    CompleteOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await completeOrderUseCase(orderId: event.orderId);

      add(GetDriverOrdersEvent(driverId: event.driverId));
    } catch (e) {
      emit(OrderFailure(error: e.toString()));
    }
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  Future<void> close() async {
    await _orderStatusSubscription?.cancel();
    await _availableOrdersRealtimeSubscription?.cancel();
    await _driverOrdersRealtimeSubscription?.cancel();

    return super.close();
  }
}

// ============================================================================
// INTERNAL REALTIME EVENTS
// ============================================================================

class _OrderRealtimeUpdatedEvent extends OrderEvent {
  final OrderEntity order;

  const _OrderRealtimeUpdatedEvent({required this.order});

  @override
  List<Object?> get props => [order];
}

class _OrderRealtimeErrorEvent extends OrderEvent {
  const _OrderRealtimeErrorEvent();
}
