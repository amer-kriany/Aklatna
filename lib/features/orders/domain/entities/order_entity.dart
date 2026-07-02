import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:aklatna/features/orders/order_type.dart';

class OrderEntity {
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
  OrderEntity({
    required this.businessId,
    required this.customerId,
    required this.customername,
    required this.customerPhone,
    required this.items,
    this.deliveryAddress,
    required this.totalPrice,
    required this.orderType, required this.id, required this.orderNumber, required this.createdAt,required this.orderStatus,
  });
}
