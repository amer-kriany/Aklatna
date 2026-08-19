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
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? description;
  final String? businessLogo;
  final String? businessName;
  final double totalPrice;
  final double deliveryFee;
  final OrderType orderType;
  final OrderStatus orderStatus;
  final DateTime? scheduledFor;
  final int? estimatedPreparationTime;
  final double? subtotal;
  final String? driverId;
final DateTime? pickedUpAt;
final DateTime? deliveredAt;

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
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.totalPrice,
    required this.deliveryFee,
    required this.orderType,
    required this.orderStatus,
    this.scheduledFor,
    this.description,
    this.businessLogo,
    this.businessName,
    this.estimatedPreparationTime,
    this.driverId, this.pickedUpAt, this.deliveredAt,  this.subtotal,
  });

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'customer_id': customerId,
      'customer_name': customername,
      'customer_phone': customerPhone,
      'items': items.map((e) => e.toJson()).toList(),
      'delivery_address': deliveryAddress,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'total_price': totalPrice,
      'delivery_fee': deliveryFee,
      'order_type': orderType.name,
      'description': description,
      'business_logo': businessLogo,
      'business_name': businessName,
      'order_status': 'pending',
    'scheduled_for': scheduledFor?.toUtc().toIso8601String(),
      // id, created_at, order_number — DB-generated, not sent from client
      // estimated_preparation_time — set later by the restaurant dashboard
      // driver_id — set later when a driver claims the order
    };
  }

  factory OrderModel.fromSupabase(Map<String, dynamic> orders) {
    String asStringOrEmpty(dynamic value) => value?.toString() ?? '';
    String? asNullableString(dynamic value) => value?.toString();

    double asDoubleOrZero(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int? asNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
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

    // BUGFIX: explicit switch instead of relying on enum .name, since
    // 'out_for_delivery' (snake_case DB value) would never match
    // OrderStatus.outForDelivery.name (camelCase) via firstWhere,
    // silently falling back to `pending` for every such order.
    OrderStatus asOrderStatus(dynamic value) {
      final normalized = value?.toString();
      switch (normalized) {
        case 'pending':
          return OrderStatus.pending;
        case 'preparing':
          return OrderStatus.preparing;
        case 'ready':
          return OrderStatus.ready;
        case 'out_for_delivery':
          return OrderStatus.outForDelivery;
        case 'completed':
          return OrderStatus.completed;
        case 'cancelled':
          return OrderStatus.cancelled;
        default:
          return OrderStatus.pending;
      }
    }

    List<CartItem> asCartItems(dynamic value) {
      try {
        if (value is! List) return <CartItem>[];
        return value
            .whereType<Map>()
            .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (e) {
        return <CartItem>[];
      }
    }

    return  OrderModel(
  id: asStringOrEmpty(orders['id']),
  businessId: asStringOrEmpty(orders['business_id']),
  customerId: asStringOrEmpty(orders['customer_id']),
  customername: asStringOrEmpty(orders['customer_name']),
  customerPhone: asStringOrEmpty(orders['customer_phone']),
  items: asCartItems(orders['items']),

  businessName: asNullableString(orders['business_name']),
  businessLogo: asNullableString(orders['business_logo']),

  totalPrice: asDoubleOrZero(orders['total_price']),
  subtotal: asDoubleOrZero(orders['subtotal']),
  deliveryFee: asDoubleOrZero(orders['delivery_fee']),

  orderType: asOrderType(orders['order_type']),
  deliveryAddress: asNullableString(orders['delivery_address']),
  deliveryLatitude: orders['delivery_latitude'] == null
      ? null
      : asDoubleOrZero(orders['delivery_latitude']),
  deliveryLongitude: orders['delivery_longitude'] == null
      ? null
      : asDoubleOrZero(orders['delivery_longitude']),

  orderNumber: asStringOrEmpty(orders['order_number']),
  createdAt: asDateOrEpoch(orders['created_at']),

  orderStatus: asOrderStatus(orders['order_status']),

  description: asNullableString(orders['description']),
  scheduledFor: asNullableDate(orders['scheduled_for']),

  estimatedPreparationTime: asNullableInt(
    orders['estimated_preparation_time'],
  ),

  driverId: asNullableString(
    orders['driver_id'],
  ),

  pickedUpAt: asNullableDate(
    orders['picked_up_at'],
  ),

  deliveredAt: asNullableDate(
    orders['delivered_at'],
  ),
);
  }
}