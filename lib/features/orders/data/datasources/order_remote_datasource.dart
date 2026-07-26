import 'package:aklatna/features/orders/data/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRemoteDatasource {
  final supabase = Supabase.instance.client;

  // ============================================================
  // PLACE ORDER
  // ============================================================

  Future<void> placeOrder(OrderModel order) async {
    try {
      await supabase.from('order').insert(order.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // GET CUSTOMER ORDERS
  // ============================================================

  Future<List<OrderModel>> customerOrders(String customerId) async {
    try {
      final orders = await supabase
          .from('order')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return orders
          .map<OrderModel>(
            (e) => OrderModel.fromSupabase(e),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // REALTIME ORDER STATUS
  // ============================================================

  Stream<OrderModel> watchOrderStatus(String orderId) {
    return supabase
        .from('order')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((rows) {
          if (rows.isEmpty) {
            throw Exception('Order not found');
          }

          return OrderModel.fromSupabase(rows.first);
        });
  }
}