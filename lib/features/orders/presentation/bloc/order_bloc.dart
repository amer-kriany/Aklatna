import 'dart:async';

import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/domain/usecases/accept_order_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/complete_order_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/get_available_orders_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/get_customer_orders_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/mark_out_for_delivery_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/orderStatusUseCase.dart';
import 'package:aklatna/features/orders/domain/usecases/place_order_usecase.dart';
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
  final GetCustomerOrdersUseCase customerOrdersUsecase;

  StreamSubscription<OrderEntity>? _orderStatusSubscription;

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
    required this.watchOrderStatusUsecase, required this.getAvailableOrdersUseCase, required this.acceptOrderUseCase, required this.markOutForDeliveryUseCase, required this.completeOrderUseCase,
  }) : super(OrderInitial()) {
    on<PlaceOrderEvent>(_placeOrder);
    on<GetCustomerOrdersEvent>(_getCustomerOrders);
    on<WatchOrderStatusEvent>(_watchOrderStatus);
    on<GetAvailableOrdersEvent>(_getAvailableOrders);
  on<AcceptOrderEvent>(_acceptOrder);
  on<MarkOutForDeliveryEvent>(_markOutForDelivery);
  on<CompleteOrderEvent>(_completeOrder);

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
          message: 'لديك طلب قيد التنفيذ حالياً، لا يمكنك إنشاء طلب جديد حتى يكتمل أو يُلغى',
        ),
      );
      return;
    }

    emit(OrderLoading());

    try {
      await placeOrderUsecase(event.order);

      emit(OrderPlaced());
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
    emit(OrderLoading());

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
          add(
            WatchOrderStatusEvent(
              orderId: ongoingOrder.id!,
            ),
          );
        }
      }
    } catch (e) {
      emit(
        OrderFailure(
          error: e.toString(),
        ),
      );
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
    final currentState = state;

    if (currentState is! CustomerOrdersFetched) {
      // Still keep _lastKnownOrders in sync even if the UI moved
      // to a different state (e.g. right after placing a new order).
      _lastKnownOrders = _lastKnownOrders.map((order) {
        if (order.id == event.order.id) {
          return event.order;
        }
        return order;
      }).toList();
      return;
    }

    final updatedOrders = currentState.orders.map((order) {
      if (order.id == event.order.id) {
        return event.order;
      }

      return order;
    }).toList();

    _lastKnownOrders = updatedOrders;

    emit(
      CustomerOrdersFetched(
        orders: updatedOrders,
      ),
    );

    // ----------------------------------------------------------
    // If the order just became completed/cancelled, stop
    // watching it — nothing left to listen to and it avoids a
    // dangling subscription on an order that will never change
    // again.
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

  bool _isOngoing(OrderEntity order) {
    switch (order.orderStatus) {
      case OrderStatus.pending:
      case OrderStatus.preparing:
      case OrderStatus.ready:
      case OrderStatus.outForDelivery:
        return true;

      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return false;
    }
  }
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

    emit(
      AvailableOrdersLoaded(
        orders: orders,
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

    add(
      WatchOrderStatusEvent(
        orderId: event.orderId,
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


