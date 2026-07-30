import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:aklatna/features/orders/order_type.dart';

class OrderEntity {
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

  OrderEntity({
    this.id,
    this.orderNumber,
    this.createdAt,

    required this.businessId,
    required this.customerId,
    required this.customername,
    required this.customerPhone,

    required this.items,

    this.deliveryAddress,
    this.description,

    this.businessLogo,
    this.businessName,

    required this.totalPrice,

    required this.orderType,
    required this.orderStatus,

    this.scheduledFor,

    this.estimatedPreparationTime,
  });

  OrderEntity copyWith({
    String? id,
    String? orderNumber,
    DateTime? createdAt,

    String? businessId,
    String? customerId,
    String? customername,
    String? customerPhone,

    List<CartItem>? items,

    String? deliveryAddress,
    String? description,

    String? businessLogo,
    String? businessName,

    double? totalPrice,

    OrderType? orderType,
    OrderStatus? orderStatus,

    DateTime? scheduledFor,

    int? estimatedPreparationTime,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      createdAt: createdAt ?? this.createdAt,

      businessId: businessId ?? this.businessId,
      customerId: customerId ?? this.customerId,
      customername: customername ?? this.customername,
      customerPhone: customerPhone ?? this.customerPhone,

      items: items ?? this.items,

      deliveryAddress:
          deliveryAddress ?? this.deliveryAddress,

      description:
          description ?? this.description,

      businessLogo:
          businessLogo ?? this.businessLogo,

      businessName:
          businessName ?? this.businessName,

      totalPrice:
          totalPrice ?? this.totalPrice,

      orderType:
          orderType ?? this.orderType,

      orderStatus:
          orderStatus ?? this.orderStatus,

      scheduledFor:
          scheduledFor ?? this.scheduledFor,

      estimatedPreparationTime:
          estimatedPreparationTime ??
              this.estimatedPreparationTime,
    );
  }
}