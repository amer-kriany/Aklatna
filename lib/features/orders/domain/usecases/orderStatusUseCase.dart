import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';

class Orderstatususecase {
  final OrderRepository orderRepositoryImpl;
  Orderstatususecase({required this.orderRepositoryImpl});

  Stream<OrderEntity> call(String orderId) {
    return orderRepositoryImpl.watchOrderStatus(orderId);
  }
}