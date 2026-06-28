import 'package:aklatna/features/orders/data/models/order_model.dart';

abstract class OrderRepository {
  Future<bool> placeOrder(OrderModel order);
}
