import 'package:aklatna/features/orders/data/models/order_model.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<void> placeOrder(OrderEntity order);
  Future<List<OrderEntity>> customerOrders(String customerID);
  Stream<OrderEntity> watchOrderStatus(String orderId);
}
