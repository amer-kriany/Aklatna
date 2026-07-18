import 'package:aklatna/features/orders/data/models/order_model.dart';
import 'package:aklatna/features/orders/data/repositories/order_repository_impl.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';

class PlaceOrderUsecase {
  final OrderRepositoryImpl orderRepositoryImpl;
  PlaceOrderUsecase({required this.orderRepositoryImpl, });

  Future<void> call(OrderEntity order) async {
    return await orderRepositoryImpl.placeOrder(order) ;
  }
}
