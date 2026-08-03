import 'package:aklatna/features/cart/domain/entities/cartItem.dart';

class CartState {
  final List<CartItem> items;
  final double totalPrice;
  final String? businessId; // locked to one restaurant at a time
  final String? businessName;
  final String? businessLogo;

  CartState({
    required this.businessId,
    required this.items,
    required this.totalPrice,
    this.businessName,
    this.businessLogo,
  });

  factory CartState.initial() => CartState(
        items: [],
        totalPrice: 0.0,
        businessId: null,
        businessName: null,
        businessLogo: null,
      );

  CartState copyWith({
    List<CartItem>? items,
    double? totalPrice,
    String? businessId,
    String? businessName,
    String? businessLogo,
    bool clearBusinessId = false,
  }) {
    return CartState(
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      businessId: clearBusinessId ? null : (businessId ?? this.businessId),
      businessName: clearBusinessId ? null : (businessName ?? this.businessName),
      businessLogo: clearBusinessId ? null : (businessLogo ?? this.businessLogo),
    );
  }
}