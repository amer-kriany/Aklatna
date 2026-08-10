import 'dart:async';

import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/domain/usecases/accept_order_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/complete_order_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/getDriverOrdersUseCase.dart';
import 'package:aklatna/features/orders/domain/usecases/get_available_orders_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/get_customer_orders_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/get_next_scheduled_order_usecase.dart';
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
  final GetNextScheduledOrderUseCase getNextScheduledOrderUseCase;
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

  Timer? _scheduledOrdersTimer;

  // --------------------------------------------------------------
  // Keeps the last known orders list around even while state is
  // OrderLoading/OrderPlaced.
  // --------------------------------------------------------------

List<OrderEntity> _lastKnownOrders = [];
  OrderBloc({
    required this.placeOrderUsecase,
    required this.customerOrdersUsecase,
    required this.watchOrderStatusUsecase,
    required this.getAvailableOrdersUseCase,
    required this.getNextScheduledOrderUseCase,
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

  Future _placeOrder(
    PlaceOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
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

  Future _getCustomerOrders(
    GetCustomerOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    try {
      final orders = await customerOrdersUsecase(event.customerId);

      _lastKnownOrders = orders;

      emit(
        CustomerOrdersFetched(
          orders: orders,
        ),
      );

      final ongoingOrders = orders.where(_isOngoing).toList();

      if (ongoingOrders.isNotEmpty) {
        final ongoingOrder = ongoingOrders.first;

        if (ongoingOrder.id != null) {
          add(
            WatchOrderStatusEvent(
              orderId: ongoingOrder.id!,
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
  // REALTIME ORDER STATUS
  // ============================================================

  Future _watchOrderStatus(
    WatchOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    await _orderStatusSubscription?.cancel();

    _orderStatusSubscription =
        watchOrderStatusUsecase(event.orderId).listen(
      (updatedOrder) {
        add(
          _OrderRealtimeUpdatedEvent(
            order: updatedOrder,
          ),
        );
      },
      onError: (error) {
        add(
          const _OrderRealtimeErrorEvent(),
        );
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
    final previousOrder =
        _lastKnownOrders.cast<OrderEntity?>().firstWhere(
              (order) => order?.id == event.order.id,
              orElse: () => null,
            );

    final wasOngoing =
        previousOrder != null && _isOngoing(previousOrder);

    final isNowCompleted =
        event.order.orderStatus == OrderStatus.completed;

    final justCompleted =
        wasOngoing && isNowCompleted;

    final updatedOrders = _lastKnownOrders.map((order) {
      if (order.id == event.order.id) {
        return event.order;
      }

      return order;
    }).toList();

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
    // Keep the existing state.
  }

  // ============================================================
  // ONGOING CHECK
  // ============================================================

  bool _isOngoing(OrderEntity order) =>
      order.orderStatus.isOngoing;

  // ============================================================
  // DRIVER - AVAILABLE ORDERS
  // ============================================================

  Future _getAvailableOrders(
    GetAvailableOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      final orders = await getAvailableOrdersUseCase();

      final driverOrders =
          await getDriverOrdersUseCase(event.driverId);

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

      // Schedule the exact moment when the nearest future
      // scheduled order should become visible.
      await _scheduleNextScheduledOrderRefresh(
        event.driverId,
      );

      // Start realtime listener once.
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
  // SCHEDULE NEXT SCHEDULED ORDER REFRESH
  // ============================================================

  Future<void> _scheduleNextScheduledOrderRefresh(
    String driverId,
  ) async {
    _scheduledOrdersTimer?.cancel();
    _scheduledOrdersTimer = null;

    try {
      final nextOrder =
          await getNextScheduledOrderUseCase();

      if (nextOrder == null ||
          nextOrder.scheduledFor == null) {
        return;
      }

      final now = DateTime.now();

      // Scheduled order becomes available 30 minutes before
      // its scheduled time.
      final refreshAt =
          nextOrder.scheduledFor!.subtract(
        const Duration(minutes: 30),
      );

      final delay = refreshAt.difference(now);

      // If it already entered the 30-minute window,
      // refresh immediately.
      if (delay.isNegative) {
        add(
          GetAvailableOrdersEvent(
            driverId: driverId,
          ),
        );
        return;
      }

      _scheduledOrdersTimer = Timer(
        delay,
        () {
          add(
            GetAvailableOrdersEvent(
              driverId: driverId,
            ),
          );
        },
      );
    } catch (_) {
      // If scheduling fails, realtime still continues working.
    }
  }

  // ============================================================
  // DRIVER - ACCEPT ORDER
  // ============================================================

  Future _acceptOrder(
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
    }
  }

  // ============================================================
  // DRIVER - OUT FOR DELIVERY
  // ============================================================

  Future _markOutForDelivery(
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
  // DRIVER - MY DELIVERIES
  // ============================================================

  Future _getDriverOrders(
    GetDriverOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      final orders =
          await getDriverOrdersUseCase(
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

  Future _completeOrder(
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
    _scheduledOrdersTimer?.cancel();

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

  const _OrderRealtimeUpdatedEvent({
    required this.order,
  });

  @override
  List<Object?> get props => [order];
}

class _OrderRealtimeErrorEvent extends OrderEvent {
  const _OrderRealtimeErrorEvent();
}