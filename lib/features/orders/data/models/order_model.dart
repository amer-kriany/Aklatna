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
  final String? description;

  final String? businessLogo;
  final String? businessName;

  final double totalPrice;

  final OrderType orderType;
  final OrderStatus orderStatus;

  final DateTime? scheduledFor;

  // Estimated preparation time in minutes.
  final int? estimatedPreparationTime;

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
    this.description,
    this.businessLogo,
    this.businessName,
    this.estimatedPreparationTime,
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

      'description': description,

      'business_logo': businessLogo,
      'business_name': businessName,

      'order_status': 'pending',

      'scheduled_for': scheduledFor?.toIso8601String(),

      // Do NOT send this when creating the order.
      // Restaurant/dashboard will update it later.
    };
  }

  factory OrderModel.fromSupabase(
    
    Map<String, dynamic> orders,
  ) {
    print(
  'ESTIMATED TIME FROM SUPABASE: '
  '${orders['estimated_preparation_time']}',
);
    String asStringOrEmpty(dynamic value) {
      return value?.toString() ?? '';
    }

    String? asNullableString(dynamic value) {
      return value?.toString();
    }

    double asDoubleOrZero(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }

      return double.tryParse(
            value?.toString() ?? '',
          ) ??
          0;
    }

    int? asNullableInt(dynamic value) {
      if (value == null) {
        return null;
      }

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(
        value.toString(),
      );
    }

    DateTime asDateOrEpoch(dynamic value) {
      if (value is DateTime) {
        return value;
      }

      return DateTime.tryParse(
            value?.toString() ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    DateTime? asNullableDate(dynamic value) {
      if (value == null) {
        return null;
      }

      return DateTime.tryParse(
        value.toString(),
      );
    }

    OrderType asOrderType(dynamic value) {
      final normalized = value?.toString();

      if (normalized == null) {
        return OrderType.delivery;
      }

      return OrderType.values.firstWhere(
        (type) => type.name == normalized,
        orElse: () => OrderType.delivery,
      );
    }

    OrderStatus asOrderStatus(dynamic value) {
      final normalized = value?.toString();

      if (normalized == null) {
        return OrderStatus.pending;
      }

      return OrderStatus.values.firstWhere(
        (status) => status.name == normalized,
        orElse: () => OrderStatus.pending,
      );
    }

    List<CartItem> asCartItems(dynamic value) {
      try {
        if (value is! List) {
          return <CartItem>[];
        }

        return value
            .whereType<Map>()
            .map(
              (e) => CartItem.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();
      } catch (e) {
        return <CartItem>[];
      }
    }

    return OrderModel(
      id: asStringOrEmpty(orders['id']),

      orderNumber: asStringOrEmpty(
        orders['order_number'],
      ),

      createdAt: asDateOrEpoch(
        orders['created_at'],
      ),

      businessId: asStringOrEmpty(
        orders['business_id'],
      ),

      customerId: asStringOrEmpty(
        orders['customer_id'],
      ),

      customername: asStringOrEmpty(
        orders['customer_name'],
      ),

      customerPhone: asStringOrEmpty(
        orders['customer_phone'],
      ),

      items: asCartItems(
        orders['items'],
      ),

      businessName: asNullableString(
        orders['business_name'],
      ),

      businessLogo: asNullableString(
        orders['business_logo'],
      ),

      totalPrice: asDoubleOrZero(
        orders['total_price'],
      ),

      orderType: asOrderType(
        orders['order_type'],
      ),

      deliveryAddress: asNullableString(
        orders['delivery_address'],
      ),

      orderStatus: asOrderStatus(
        orders['order_status'],
      ),

      description: asNullableString(
        orders['description'],
      ),

      scheduledFor: asNullableDate(
        orders['scheduled_for'],
      ),

      // Supabase int4 -> Dart int?
      estimatedPreparationTime: asNullableInt(
        orders['estimated_preparation_time'],
      ),
      
    );
    
  }
  
}