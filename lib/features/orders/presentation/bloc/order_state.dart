part of 'order_bloc.dart';

sealed class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

// ============================================================
// INITIAL
// ============================================================

final class OrderInitial extends OrderState {}

// ============================================================
// LOADING
// ============================================================

final class OrderLoading extends OrderState {}

// ============================================================
// SUCCESS
// ============================================================

final class OrderSuccess extends OrderState {
  final String message;

  const OrderSuccess({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

// ============================================================
// CUSTOMER ORDERS
// ============================================================

final class CustomerOrdersFetched extends OrderState {
  final List<OrderEntity> orders;

  const CustomerOrdersFetched({
    required this.orders,
  });

  @override
  List<Object?> get props => [orders];
  // ----------------------------------------------------------
  // Update one order without replacing the whole list
  // ----------------------------------------------------------

  CustomerOrdersFetched updateOrder(OrderEntity updatedOrder) {
    final updatedOrders = orders.map((order) {
      if (order.id == updatedOrder.id) {
        return updatedOrder;
      }

      return order;
    }).toList();

    return CustomerOrdersFetched(
      orders: updatedOrders,
    );
  }// ----------------------------------------------------------
  // Single source of truth for "customer has an active order".
  // Used by CartPage/CheckoutPage guards so the ongoing-status
  // list (pending/preparing/ready) is defined in exactly one
  // place instead of being copy-pasted into every widget.
  // ----------------------------------------------------------

  bool get hasActiveOrder => orders.any((order) =>
      order.orderStatus == OrderStatus.pending ||
      order.orderStatus == OrderStatus.preparing ||
      order.orderStatus == OrderStatus.ready);
}



// ============================================================
// FAILURE
// ============================================================

final class OrderFailure extends OrderState {
  final String error;

  const OrderFailure({
    required this.error,
  });

  @override
  List<Object?> get props => [error];
}

// ============================================================
// ORDER STATUS ERROR
// ============================================================

final class OrderStatusError extends OrderState {
  final String error;

  const OrderStatusError({
    required this.error,
  });

  @override
  List<Object?> get props => [error];
}

// ============================================================
// PLACING
// ============================================================

final class OrderPlacing extends OrderState {}

// ============================================================
// ORDER PLACED
// ============================================================

final class OrderPlaced extends OrderState {}

// ============================================================
// ORDER ERROR
// ============================================================

final class OrderError extends OrderState {
  final String message;

  const OrderError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class AvailableOrdersLoaded extends OrderState {
  final List<OrderEntity> orders;

  const AvailableOrdersLoaded({
    required this.orders,
  });

  @override
  List<Object?> get props => [orders];
}