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
  // DRIVER - REALTIME AVAILABLE ORDERS CHANGES
  // ============================================================

  Stream<void> watchAvailableOrdersChanges() {
    return supabase
        .from('order')
        .stream(primaryKey: ['id'])
        .eq('order_type', 'delivery')
        .map((_) {});
  }

  // ============================================================
  // DRIVER - GET AVAILABLE ORDERS
  // ============================================================
  //
  // Normal orders:
  //   scheduled_for IS NULL
  //
  // Scheduled orders:
  //   only visible 30 minutes before scheduled_for.
  //
  // No schema change required.
  // ============================================================

  Future<List<OrderModel>> getAvailableOrders() async {
    final availableUntil = DateTime.now()
        .add(const Duration(minutes: 30))
        .toIso8601String();

    final orders = await supabase
        .from('order')
        .select()
        .eq('order_status', 'pending')
        .isFilter('driver_id', null)
        .or(
          'scheduled_for.is.null,scheduled_for.lte.$availableUntil',
        )
        .order('created_at');

    return orders
        .map<OrderModel>(
          (e) => OrderModel.fromSupabase(e),
        )
        .toList();
  }

  // ============================================================
  // DRIVER - GET NEXT FUTURE SCHEDULED ORDER
  // ============================================================
  //
  // This is NOT used to show the order.
  //
  // It is only used by the driver BLoC to know when it should
  // refresh the available-orders list.
  // ============================================================

  Future<OrderModel?> getNextScheduledOrder() async {
    final orders = await supabase
        .from('order')
        .select()
        .eq('order_status', 'pending')
        .isFilter('driver_id', null)
        .not('scheduled_for', 'is', null)
        .gt(
          'scheduled_for',
          DateTime.now().toIso8601String(),
        )
        .order('scheduled_for', ascending: true)
        .limit(1);

    if (orders.isEmpty) {
      return null;
    }

    return OrderModel.fromSupabase(orders.first);
  }

  // ============================================================
  // DRIVER - REALTIME DRIVER ORDERS
  // ============================================================

  Stream<void> watchDriverOrdersChanges(String driverId) {
    return supabase
        .from('order')
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .map((_) {});
  }

  // ============================================================
  // DRIVER - GET DRIVER ORDERS
  // ============================================================

  Future<List<OrderModel>> getDriverOrders(String driverId) async {
    final orders = await supabase
        .from('order')
        .select()
        .eq('driver_id', driverId)
        .order('created_at', ascending: false);

    return orders
        .map<OrderModel>(
          (e) => OrderModel.fromSupabase(e),
        )
        .toList();
  }

  // ============================================================
  // ACCEPT ORDER
  // ============================================================

  Future<void> acceptOrder({
    required String orderId,
    required String driverId,
  }) async {
    await supabase
        .from('order')
        .update({
          'driver_id': driverId,
        })
        .eq('id', orderId);
  }

  // ============================================================
  // OUT FOR DELIVERY
  // ============================================================

  Future<void> markOutForDelivery({
    required String orderId,
  }) async {
    await supabase
        .from('order')
        .update({
          'order_status': 'out_for_delivery',
          'picked_up_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId);
  }

  // ============================================================
  // COMPLETE ORDER
  // ============================================================

  Future<void> completeOrder({
    required String orderId,
  }) async {
    await supabase
        .from('order')
        .update({
          'order_status': 'completed',
          'delivered_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId);
  }
}