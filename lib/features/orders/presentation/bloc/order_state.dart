part of 'order_bloc.dart';

sealed class OrderState extends Equatable {
  const OrderState();
  
  @override
  List<Object> get props => [];
}

final class OrderInitial extends OrderState {}
final class OrderLoading extends OrderState {}
final class OrderSuccess extends OrderState {
  final String message;
  const OrderSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
final class OrderFailure extends OrderState {
  final String error;
  const OrderFailure({required this.error});
  @override
  List<Object> get props => [error];
}
