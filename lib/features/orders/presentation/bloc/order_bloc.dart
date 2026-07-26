import 'package:aklatna/features/orders/data/models/order_model.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/domain/usecases/get_customer_orders_usecase.dart';
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
  final GetCustomerOrdersUseCase customerOrdersUsecase;
  OrderBloc( {
   required this.placeOrderUsecase,
   required this.customerOrdersUsecase, 
    required this.watchOrderStatusUsecase, 
  }) : super(OrderInitial()) {
    on<PlaceOrderEvent>(_placeOrder);
    on<GetCustomerOrdersEvent>(_getCustomerOrders);
    on<WatchOrderStatusEvent>(_watchOrderStatus);
  }
  // place an order
  Future<void> _placeOrder(
    PlaceOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      await placeOrderUsecase(event.order);

      emit(OrderPlaced());

    } catch (e) {
      emit(OrderError(message: e.toString() ));
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

  // watch order status
  Future<void> _watchOrderStatus(
    WatchOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async{
    await
    emit.forEach(
      watchOrderStatusUsecase(event.orderId),
      onData: (OrderEntity order) =>
          OrderStatusUpdated(status: order.orderStatus),
          onError: (_,__)=>OrderStatusError(error: "حدث خطأ")
    );
  }
}
