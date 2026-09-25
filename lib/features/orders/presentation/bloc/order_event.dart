part of 'order_bloc.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class PlaceOrderEvent extends OrderEvent {
  final OrderEntity order;
  final String customerId;

  const PlaceOrderEvent({
    required this.order,
    required this.customerId,
  });

  @override
  List<Object?> get props => [order, customerId];
}

class GetCustomerOrdersEvent extends OrderEvent {
  final String customerId;
  const GetCustomerOrdersEvent({required this.customerId});
  @override
  List<Object?> get props => [customerId];
}

class WatchOrderStatusEvent extends OrderEvent {
  final String orderId;
  const WatchOrderStatusEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}