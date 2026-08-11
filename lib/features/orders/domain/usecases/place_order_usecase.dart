import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';

class PlaceOrderUsecase {
  final OrderRepository orderRepositoryImpl;
  PlaceOrderUsecase({required this.orderRepositoryImpl});

  Future<void> call(OrderEntity order) async {
    return await orderRepositoryImpl.placeOrder(order);
  }
}