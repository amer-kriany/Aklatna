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
  // ============================================================
  // DRIVER
  // ============================================================

  Future<List<OrderModel>> getAvailableOrders() async {
    final orders = await supabase
        .from('order')
        .select()
        .eq('order_status', 'pending')
        .isFilter('driver_id', null)
        .order('created_at');

    return orders
        .map<OrderModel>((e) => OrderModel.fromSupabase(e))
        .toList();
  }

  Future<List<OrderModel>> getDriverOrders(String driverId) async {
    final orders = await supabase
        .from('order')
        .select()
        .eq('driver_id', driverId)
        .order('created_at', ascending: false);

    return orders
        .map<OrderModel>((e) => OrderModel.fromSupabase(e))
        .toList();
  }

  Future<void> acceptOrder({
    required String orderId,
    required String driverId,
  }) async {
    await supabase.from('order').update({
      'driver_id': driverId,
    }).eq('id', orderId);
  }

  Future<void> markOutForDelivery({
    required String orderId,
  }) async {
    await supabase.from('order').update({
      'order_status': 'out_for_delivery',
      'picked_up_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

  Future<void> completeOrder({
  required String orderId,
}) async {
  await supabase.from('order').update({
    'order_status': 'completed',
    'delivered_at': DateTime.now().toIso8601String(),
  }).eq('id', orderId);
}
}