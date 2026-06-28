import 'package:aklatna/features/orders/data/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRemoteDatasource {
  final supabase = Supabase.instance.client;

  // place an order
  Future<bool> placeOrder(OrderModel order) async {
    try {
      return await supabase.from('order').insert(order.ordretoJson());
    } catch (e) {
      rethrow;
    }
  }

  // get customer's orders history
  Future<List<OrderModel>> customerOrders(String customerId) async {
    try {
      final orders = await supabase
          .from('order')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      return orders.map((e)=>OrderModel.fromSupabase(e)).toList() ;
    } catch (e) {
      rethrow;
    }
  }
}
