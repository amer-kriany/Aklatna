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

  StreamSubscription? _orderStatusSubscription;

  StreamSubscription? _availableOrdersRealtimeSubscription;

  StreamSubscription? _driverOrdersRealtimeSubscription;

  // ============================================================
  // LAST KNOWN CUSTOMER ORDERS
  // ============================================================

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
    // CUSTOMER
    on<PlaceOrderEvent>(_placeOrder);
    on<GetCustomerOrdersEvent>(_getCustomerOrders);
    on<WatchOrderStatusEvent>(_watchOrderStatus);

    // DRIVER
    on<GetAvailableOrdersEvent>(_getAvailableOrders);
    on<AcceptOrderEvent>(_acceptOrder);
    on<MarkOutForDeliveryEvent>(_markOutForDelivery);
    on<CompleteOrderEvent>(_completeOrder);
    on<GetDriverOrdersEvent>(_getDriverOrders);

    // INTERNAL REALTIME EVENTS
    on<_OrderRealtimeUpdatedEvent>(_updateOrderInState);
    on<_OrderRealtimeErrorEvent>(_handleRealtimeError);
  }

  // ============================================================
  // SCHEDULED ORDER RELEASE
  // ============================================================
  //
  // A normal order:
  //     scheduledFor == null
  //     -> immediately active
  //
  // A scheduled order:
  //     scheduledFor != null
  //     -> hidden from tracking until 30 minutes before
  //
  // Example:
  //
  // scheduledFor = 22:56
  // release time = 22:26
  //
  // Before 22:26 -> frozen
  // At 22:26      -> behaves like normal order
  //
  // ============================================================

  bool _isScheduledOrderReleased(OrderEntity order) {
    if (order.scheduledFor == null) {
      return true;
    }

    final releaseTime = order.scheduledFor!.subtract(
      const Duration(minutes: 30),
    );

    return !DateTime.now().isBefore(releaseTime);
  }

  // ============================================================
  // CUSTOMER TRACKING ORDER
  // ============================================================
  //
  // IMPORTANT:
  // Scheduled orders do NOT appear in the HomePage tracking card
  // until they enter the 30-minute window.
  //
  // ============================================================

  bool _isOngoingForTracking(OrderEntity order) {
    if (!order.orderStatus.isOngoing) {
      return false;
    }

    if (!_isScheduledOrderReleased(order)) {
      return false;
    }

    return true;
  }

  // ============================================================
  // ACTIVE ORDER CHECK
  // ============================================================
  //
  // A scheduled order is still an active order from the customer's
  // perspective.
  //
  // Therefore the customer cannot create another order while a
  // scheduled order is waiting.
  //
  // ============================================================

  bool _isOngoingForActiveOrder(OrderEntity order) {
    return order.orderStatus.isOngoing;
  }

  // ============================================================
  // PLACE ORDER
  // ============================================================

  Future<void> _placeOrder(
    PlaceOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    final hasActiveOrder = _lastKnownOrders.any(
      _isOngoingForActiveOrder,
    );

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

      add(
        GetCustomerOrdersEvent(
          customerId: event.customerId,
        ),
      );
    } catch (e) {
      emit(
        OrderError(
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // GET CUSTOMER ORDERS
  // ============================================================

  Future<void> _getCustomerOrders(
    GetCustomerOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    try {
      final orders = await customerOrdersUsecase(
        event.customerId,
      );

      _lastKnownOrders = orders;

      emit(
        CustomerOrdersFetched(
          orders: orders,
        ),
      );

      // Only watch an order that is actually released.
      //
      // Scheduled order more than 30 minutes away:
      //     no tracking subscription
      //
      // Scheduled order inside 30 minutes:
      //     realtime tracking starts
      //
      final trackingOrders = orders
          .where(_isOngoingForTracking)
          .toList();

      if (trackingOrders.isNotEmpty) {
        final trackingOrder = trackingOrders.first;

        if (trackingOrder.id != null) {
          add(
            WatchOrderStatusEvent(
              orderId: trackingOrder.id!,
            ),
          );
        }
      }
    } catch (e) {
      if (_lastKnownOrders.isEmpty) {
        emit(
          OrderFailure(
            error: e.toString(),
          ),
        );
      }
    }
  }

  // ============================================================
  // WATCH ORDER STATUS
  // ============================================================

  Future<void> _watchOrderStatus(
    WatchOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    await _orderStatusSubscription?.cancel();

    _orderStatusSubscription =
        watchOrderStatusUsecase(
      event.orderId,
    ).listen(
      (updatedOrder) {
        add(
          _OrderRealtimeUpdatedEvent(
            order: updatedOrder,
          ),
        );
      },
      onError: (_) {
        add(
          const _OrderRealtimeErrorEvent(),
        );
      },
    );
  }

  // ============================================================
  // REALTIME ORDER UPDATE
  // ============================================================

  void _updateOrderInState(
    _OrderRealtimeUpdatedEvent event,
    Emitter<OrderState> emit,
  ) {
    final previousOrder =
        _lastKnownOrders.cast<OrderEntity?>().firstWhere(
              (order) => order?.id == event.order.id,
              orElse: () => null,
            );

    final wasOngoing =
        previousOrder != null &&
        _isOngoingForTracking(previousOrder);

    final isNowCompleted =
        event.order.orderStatus == OrderStatus.completed;

    final justCompleted =
        wasOngoing && isNowCompleted;

    final updatedOrders = _lastKnownOrders.map(
      (order) {
        if (order.id == event.order.id) {
          return event.order;
        }

        return order;
      },
    ).toList();

    _lastKnownOrders = updatedOrders;

    if (state is CustomerOrdersFetched) {
      emit(
        CustomerOrdersFetched(
          orders: updatedOrders,
        ),
      );
    }

    if (justCompleted) {
      emit(
        OrderJustCompleted(
          order: event.order,
        ),
      );

      emit(
        CustomerOrdersFetched(
          orders: updatedOrders,
        ),
      );
    }

    // Stop realtime when the order is no longer active.
    if (!event.order.orderStatus.isOngoing) {
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
    // Keep current state.
  }

  // ============================================================
  // DRIVER - GET AVAILABLE ORDERS
  // ============================================================
  //
  // IMPORTANT:
  // The datasource controls the 30-minute scheduled-order rule.
  //
  // This BLoC simply asks for available orders.
  //
  // ============================================================

  Future<void> _getAvailableOrders(
    GetAvailableOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      final orders = await getAvailableOrdersUseCase();

      final driverOrders = await getDriverOrdersUseCase(
        event.driverId,
      );

      final totalEarnings = driverOrders
          .where(
            (o) => o.orderStatus == OrderStatus.completed,
          )
          .fold<double>(
            0,
            (sum, o) => sum + o.deliveryFee,
          );

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

      // Start realtime listener only once.
      _availableOrdersRealtimeSubscription ??=
          watchAvailableOrdersUseCase().listen(
        (_) {
          if (state is AvailableOrdersLoaded) {
            add(
              GetAvailableOrdersEvent(
                driverId: event.driverId,
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(
        OrderFailure(
          error: e.toString(),
        ),
      );
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

    if (state is AvailableOrdersLoaded) {
      final liveState =
          state as AvailableOrdersLoaded;

      emit(
        AvailableOrdersLoaded(
          orders: liveState.orders
              .where(
                (o) => o.id != event.orderId,
              )
              .toList(),
          totalEarnings: liveState.totalEarnings,
          hasActiveDelivery: true,
        ),
      );
    }

    add(
      WatchOrderStatusEvent(
        orderId: event.orderId,
      ),
    );
  } catch (e) {
    // Someone else claimed it first (or another failure) --
    // remove the now-stale card from this driver's list and
    // let them know why, instead of silently pretending it
    // just disappeared.
    if (state is AvailableOrdersLoaded) {
      final liveState =
          state as AvailableOrdersLoaded;

      emit(
        AvailableOrdersLoaded(
          orders: liveState.orders
              .where(
                (o) => o.id != event.orderId,
              )
              .toList(),
          totalEarnings: liveState.totalEarnings,
          hasActiveDelivery:
              liveState.hasActiveDelivery,
        ),
      );
    }

    emit(
      OrderAcceptFailed(
        message: e.toString().replaceFirst('Exception: ', ''),
      ),
    );

    // Re-emit AvailableOrdersLoaded right after so the list UI
    // keeps working normally -- OrderAcceptFailed is just a
    // one-shot signal for a snackbar via BlocListener.
    if (state is AvailableOrdersLoaded) {
      emit(state as AvailableOrdersLoaded);
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
      await markOutForDeliveryUseCase(
        orderId: event.orderId,
      );

      add(
        GetDriverOrdersEvent(
          driverId: event.driverId,
        ),
      );
    } catch (e) {
      emit(
        OrderFailure(
          error: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // DRIVER - GET DRIVER ORDERS
  // ============================================================

  Future<void> _getDriverOrders(
    GetDriverOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      final orders = await getDriverOrdersUseCase(
        event.driverId,
      );

      emit(
        DriverOrdersFetched(
          orders: orders,
        ),
      );

      _driverOrdersRealtimeSubscription ??=
          watchDriverOrdersUseCase(
        event.driverId,
      ).listen(
        (_) {
          if (state is DriverOrdersFetched) {
            add(
              GetDriverOrdersEvent(
                driverId: event.driverId,
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(
        OrderFailure(
          error: e.toString(),
        ),
      );
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
      await completeOrderUseCase(
        orderId: event.orderId,
      );

      add(
        GetDriverOrdersEvent(
          driverId: event.driverId,
        ),
      );
    } catch (e) {
      emit(
        OrderFailure(
          error: e.toString(),
        ),
      );
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

// ============================================================
// INTERNAL REALTIME EVENTS
// ============================================================

class _OrderRealtimeUpdatedEvent extends OrderEvent {
  final OrderEntity order;

  const _OrderRealtimeUpdatedEvent({
    required this.order,
  });

  @override
  List<Object?> get props => [order];
}

class _OrderRealtimeErrorEvent extends OrderEvent {
  const _OrderRealtimeErrorEvent();
}