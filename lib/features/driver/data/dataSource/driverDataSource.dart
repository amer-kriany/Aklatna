import 'package:aklatna/features/driver/data/model/driverModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aklatna/features/orders/data/models/order_model.dart';

class DriverRemoteDatasource {
  final supabase = Supabase.instance.client;

  // Checks whether the currently logged-in user is a driver.
  // Returns null if not a driver at all.
  Future<DriverModel?> getMyDriverProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final row = await supabase
          .from('drivers')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (row == null) return null;
      return DriverModel.fromSupabase(row);
    } catch (e) {
      rethrow;
    }
  }

  // Available orders: ready, delivery, unclaimed
  Future<List<OrderModel>> getAvailableOrders() async {
    try {
      final rows = await supabase
          .from('order')
          .select()
          .eq('order_type', 'delivery')
          .eq('order_status', 'ready')
          .filter('driver_id', 'is', null)
          .order('created_at', ascending: true);

      return rows.map<OrderModel>((e) => OrderModel.fromSupabase(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // My claimed orders (any status)
  Future<List<OrderModel>> getMyOrders() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final rows = await supabase
          .from('order')
          .select()
          .eq('driver_id', userId)
          .order('created_at', ascending: false);

      return rows.map<OrderModel>((e) => OrderModel.fromSupabase(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Claim an order — RLS enforces driver_id can only be set to self,
  // and only on orders that are currently unclaimed + ready.
  Future<void> claimOrder(String orderId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('غير مسجل الدخول');

    try {
      await supabase
          .from('order')
          .update({'driver_id': userId})
          .eq('id', orderId)
          .filter('driver_id', 'is', null);
    } catch (e) {
      rethrow;
    }
  }

  // Update status: ready -> out_for_delivery -> completed
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await supabase
          .from('order')
          .update({'order_status': newStatus})
          .eq('id', orderId);
    } catch (e) {
      rethrow;
    }
  }

  // Sum of delivery_fee for this driver's completed orders
  Future<double> getEarnings() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    try {
      final rows = await supabase
          .from('order')
          .select('delivery_fee')
          .eq('driver_id', userId)
          .eq('order_status', 'completed');

      double total = 0;
      for (final row in rows) {
        final fee = row['delivery_fee'];
        if (fee is num) total += fee.toDouble();
      }
      return total;
    } catch (e) {
      rethrow;
    }
  }
}