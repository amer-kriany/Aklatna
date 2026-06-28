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
}
