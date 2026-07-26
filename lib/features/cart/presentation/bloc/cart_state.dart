import 'package:aklatna/features/cart/domain/entities/cartItem.dart';

class CartState {
  final List<CartItem> items;
  final double totalPrice;
  final String? businessId; // locked to one restaurant at a time
  CartState({
    required this.businessId,
    required this.items,
    required this.totalPrice,
  });
  factory CartState.initial() =>
      CartState(items: [], totalPrice: 0.0, businessId: null);
      
  CartState copyWith({
  List<CartItem>? items,
  double? totalPrice,
  String? businessId,
  bool clearBusinessId = false,
}) {
  return CartState(
    items: items ?? this.items,
    totalPrice: totalPrice ?? this.totalPrice,
    businessId: clearBusinessId ? null : (businessId ?? this.businessId),
  );
}
}
