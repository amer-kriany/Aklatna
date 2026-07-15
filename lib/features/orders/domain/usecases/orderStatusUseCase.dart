import 'package:aklatna/features/orders/data/repositories/order_repository_impl.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';

class Orderstatususecase {
  final OrderRepositoryImpl orderRepositoryImpl;
  Orderstatususecase({required this.orderRepositoryImpl, required OrderRepositoryImpl orderRepository});

  Stream<OrderEntity> call(String orderId) {
    return orderRepositoryImpl.watchOrderStatus(orderId) ;
  }
}
