import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/orders/order_type.dart';

class OrderEntity {
  final String businessId;
  final String customerId;
  final String customerUsername;
  final String customerPhone;
  final List<CartItem> items;
  final String? deliveryAdress;
  final double totalPrice;
  final OrderType orderType;
  OrderEntity({
    required this.businessId,
    required this.customerId,
    required this.customerUsername,
    required this.customerPhone,
    required this.items,
    this.deliveryAdress,
    required this.totalPrice,
    required this.orderType,
  });
}
