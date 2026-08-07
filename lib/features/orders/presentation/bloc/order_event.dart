part of 'order_bloc.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class PlaceOrderEvent extends OrderEvent {
  final OrderEntity order;
  const PlaceOrderEvent({required this.order});
  @override
  List<Object?> get props => [order];
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
class GetAvailableOrdersEvent extends OrderEvent {
  const GetAvailableOrdersEvent();

  @override
  List<Object?> get props => [];
}
class AcceptOrderEvent extends OrderEvent {
  final String orderId;
  final String driverId;

  const AcceptOrderEvent({
    required this.orderId,
    required this.driverId,
  });

  @override
  List<Object?> get props => [
        orderId,
        driverId,
      ];
}
class MarkOutForDeliveryEvent extends OrderEvent {
  final String orderId;
  final String driverId;

  const MarkOutForDeliveryEvent({
    required this.orderId,
    required this.driverId,
  });

  @override
  List<Object?> get props => [orderId, driverId];
}
class CompleteOrderEvent extends OrderEvent {
  final String orderId;
  final String driverId;

  const CompleteOrderEvent({
    required this.orderId,
    required this.driverId,
  });

  @override
  List<Object?> get props => [orderId, driverId];
}
class GetDriverOrdersEvent extends OrderEvent {
  final String driverId;

  const GetDriverOrdersEvent({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}