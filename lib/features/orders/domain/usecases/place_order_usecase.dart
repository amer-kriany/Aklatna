import 'package:aklatna/features/orders/data/models/order_model.dart';
import 'package:aklatna/features/orders/data/repositories/order_repository_impl.dart';

class PlaceOrderUsecase {
  final OrderRepositoryImpl orderRepositoryImpl;
  PlaceOrderUsecase({required this.orderRepositoryImpl});

  Future<bool> call(OrderModel order) async {
    return await orderRepositoryImpl.placeOrder(order) ;
  }
}
