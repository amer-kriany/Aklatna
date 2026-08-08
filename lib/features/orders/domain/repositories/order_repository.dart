import 'package:aklatna/features/orders/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<void> placeOrder(OrderEntity order);
  Future<List<OrderEntity>> customerOrders(String customerID);
  Stream<OrderEntity> watchOrderStatus(String orderId);
Future<List<OrderEntity>> getAvailableOrders();
Stream<void> watchAvailableOrdersChanges();
Future<List<OrderEntity>> getDriverOrders(String driverId);

Future<void> acceptOrder({
  required String orderId,
  required String driverId,
});

Future<void> markOutForDelivery({
  required String orderId,
});

Future<void> completeOrder({
  required String orderId,
});}