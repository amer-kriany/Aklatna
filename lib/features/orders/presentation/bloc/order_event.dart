part of 'order_bloc.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}
class PlaceOrderEvent extends OrderEvent {
  final OrderModel order;
  const PlaceOrderEvent({required this.order});
  @override
  List<Object> get props => [order];
}