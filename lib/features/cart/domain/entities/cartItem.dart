class CartItem {
  final String itemId;
  final String nameAr;
  final double price;
  final int quantity;
  final String businessId;
  CartItem({
    required this.itemId,
    required this.nameAr,
    required this.price,
    required this.quantity,
    required this.businessId,
  });
  CartItem copyWith({
    String? itemId,
    String? nameAr,
    double? price,
    int? quantity,
    String? businessId,
  }) {
    return CartItem(
      itemId: itemId ?? this.itemId,
      nameAr: nameAr ?? this.nameAr,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      businessId: businessId ?? this.businessId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'nameAr': nameAr,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: json['item_id'],
      nameAr: json['name_ar'],
      price: json['price'],
      quantity: json['quantity'],
      businessId: json['business_id'],
    );
  }
}
