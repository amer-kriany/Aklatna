import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:aklatna/features/orders/order_type.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final String businessId;
  final String customerId;
  final String customername;
  final String customerPhone;
  final List<CartItem> items;
  final String? deliveryAddress;
  final double totalPrice;
  final OrderType orderType;
  final OrderStatus orderStatus;
  OrderModel({
    required this.businessId,
    required this.customerId,
    required this.customername,
    required this.customerPhone,
    required this.items,
    this.deliveryAddress,
    required this.totalPrice,
    required this.orderType,
    required this.id,
    required this.orderNumber,
    required this.createdAt, required this.orderStatus,
  });

  Map<String, dynamic>toJson() {
    return {
      'business_id': businessId,
      'customer_id': customerId,
      'customer_name': customername,
      'customer_phone': customerPhone,
      'items': items.map((e) => e.toJson()).toList(),
      'delivery_address': deliveryAddress,
      'total_price': totalPrice,
      'order_type': orderType.name,
      'order_status': 'pending',
    };
  }

  factory OrderModel.fromSupabase(Map<String, dynamic> orders) {
    return OrderModel(
      id: orders['id'],
      businessId: orders['business_id'],
      customerId: orders['customer_id'],
      customername: orders['customer_username'],
      customerPhone: orders['customer_phone'],
      items: (orders['items'] as List)
          .map((e) => CartItem.fromJson(e))
          .toList(),
      totalPrice: (orders['total_price'] as num).toDouble(),
      orderType: OrderType.values.byName(orders['order_type']),
deliveryAddress: orders['delviery_address'],
      orderNumber: orders['order_number'],
      createdAt: DateTime.parse(orders['created_at']),
      orderStatus: OrderStatus.values.byName(orders['order_status'])
    );
  }
}
