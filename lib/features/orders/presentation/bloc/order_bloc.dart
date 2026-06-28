import 'package:aklatna/features/orders/data/models/order_model.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/domain/usecases/get_customer_orders_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/place_order_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final PlaceOrderUsecase placeOrderUsecase;
  final GetCustomerOrdersUseCase customerOrdersUsecase;
  OrderBloc(this.placeOrderUsecase, this.customerOrdersUsecase) : super(OrderInitial()) {
    on<PlaceOrderEvent>(_placeOrder);
    on<GetCustomerOrdersEvent>(_getCustomerOrders);
  }
// place an order
  Future<void> _placeOrder(
    PlaceOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final result = await placeOrderUsecase(event.order);
      if (result) {
        emit(OrderSuccess(message: 'Order placed successfully'));
      } else {
        emit(OrderFailure(error: 'Failed to place order'));
      }
    } catch (e) {
      emit(OrderFailure(error: e.toString()));
    }
  }
  // get customer's orders history
  Future<void> _getCustomerOrders(
    GetCustomerOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await customerOrdersUsecase(event.customerId);
      emit(CustomerOrdersFetched(orders: orders));
    } catch (e) {
      emit(OrderFailure(error: e.toString()));
    }
  }
}
