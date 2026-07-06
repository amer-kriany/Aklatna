import 'package:aklatna/features/orders/data/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRemoteDatasource {
  final supabase = Supabase.instance.client;

  // place an order
  Future<void> placeOrder(OrderModel order) async {
    try {
      await supabase.from('orders').insert(order.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // get customer's orders history
  Future<List<OrderModel>> customerOrders(String customerId) async {
    try {
      final orders = await supabase
          .from('orders')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      return orders.map((e) => OrderModel.fromSupabase(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // whatch order status
  Stream<OrderModel> watchOrderStatus(String orderId) {
    return supabase
        .from("orders")
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((row) => OrderModel.fromSupabase(row.first));
  }
}
