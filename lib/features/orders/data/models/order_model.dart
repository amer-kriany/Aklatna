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
      'customer_username': customerUsername,
      'customer_phone': customerPhone,
      'items': items.map((e) => e.toJson()).toList(),
      'delivery_adress': deliveryAdress,
      'total_price': totalPrice,
      'order_type': orderType.name,
      'order_status': 'pending',
    };
  }

  
}
