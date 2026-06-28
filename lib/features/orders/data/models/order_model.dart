import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/orders/order_type.dart';

class OrderModel {
  final String businessId;
  final String customerId;
  final String customerUsername;
  final String customerPhone;
  final List<CartItem> items;
  final String? deliveryAdress;
  final double totalPrice;
  final OrderType orderType;
  OrderModel({
    required this.businessId,
    required this.customerId,
    required this.customerUsername,
    required this.customerPhone,
    required this.items,
    this.deliveryAdress,
    required this.totalPrice,
    required this.orderType,
  });

  Map<String, dynamic> ordretoJson() {
    return {
      'business_id': businessId,
      'customer_id': customerId,
      'customer_username': customerUsername,
      'customer_phone': customerPhone,
      'items': items.map((e) => e.toJson()).toList(),
      'delivery_adress': deliveryAdress,
      'total_price': totalPrice,
      'order_type': orderType.name,
      'order_status': 'pending',
    };
  }

  factory OrderModel.fromSupabase(Map<String, dynamic> orders) {
    return OrderModel(
      businessId: orders['business_id'],
      customerId: orders['customer_id'],
      customerUsername: orders['customer_username'],
      customerPhone: orders['customer_phone'],
      items: orders['items'],
      totalPrice: orders['total_price'],
      orderType: orders['orderType'],
    );
  }
}
