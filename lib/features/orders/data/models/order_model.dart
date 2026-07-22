import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:aklatna/features/orders/order_type.dart';

class OrderModel {
  final String? id;
  final String? orderNumber;
  final DateTime? createdAt;
  final String businessId;
  final String customerId;
  final String customername;
  final String customerPhone;
  final List<CartItem> items;
  final String? deliveryAddress;
  final double totalPrice;
  final OrderType orderType;
  final OrderStatus orderStatus;
  final DateTime? scheduledFor;
  OrderModel({
    this.id,
    this.orderNumber,
    this.createdAt,
    required this.businessId,
    required this.customerId,
    required this.customername,
    required this.customerPhone,
    required this.items,
    this.deliveryAddress,
    required this.totalPrice,
    required this.orderType,
    required this.orderStatus,
    this.scheduledFor,
  });

  Map<String, dynamic> toJson() {
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
      'scheduled_for': scheduledFor?.toIso8601String(),
      // id, created_at, order_number — DB-generated, not sent from client
    };
  }

  factory OrderModel.fromSupabase(Map<String, dynamic> orders) {
    String asStringOrEmpty(dynamic value) => value?.toString() ?? '';
    String? asNullableString(dynamic value) => value?.toString();

    double asDoubleOrZero(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    DateTime asDateOrEpoch(dynamic value) {
      if (value is DateTime) return value;
      return DateTime.tryParse(value?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    DateTime? asNullableDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    OrderType asOrderType(dynamic value) {
      final normalized = value?.toString();
      if (normalized == null) return OrderType.delivery;
      return OrderType.values.firstWhere(
        (type) => type.name == normalized,
        orElse: () => OrderType.delivery,
      );
    }

    OrderStatus asOrderStatus(dynamic value) {
      final normalized = value?.toString();
      if (normalized == null) return OrderStatus.pending;
      return OrderStatus.values.firstWhere(
        (status) => status.name == normalized,
        orElse: () => OrderStatus.pending,
      );
    }

    List<CartItem> asCartItems(dynamic value) {
      if (value is! List) return <CartItem>[];
      return value
          .whereType<Map>()
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return OrderModel(
      id: asStringOrEmpty(orders['id']),
      businessId: asStringOrEmpty(orders['business_id']),
      customerId: asStringOrEmpty(orders['customer_id']),
      customername: asStringOrEmpty(orders['customer_name']),
      customerPhone: asStringOrEmpty(orders['customer_phone']),
      items: asCartItems(orders['items']),
      totalPrice: asDoubleOrZero(orders['total_price']),
      orderType: asOrderType(orders['order_type']),
      deliveryAddress: asNullableString(orders['delivery_address']),
      orderNumber: asStringOrEmpty(orders['order_number']),
      createdAt: asDateOrEpoch(orders['created_at']),
      orderStatus: asOrderStatus(orders['order_status']),
      scheduledFor: asNullableDate(orders['scheduled_for']),
    );
  }
}
