class CartItem {
  final String itemId;
  final String nameAr;
  final String description;
  final String? photoUrl; // NEW
  final double price;
  final int quantity;
  final String businessId;

  CartItem({
    required this.itemId,
    required this.nameAr,
    required this.description,
    this.photoUrl,
    required this.price,
    required this.quantity,
    required this.businessId,
  });

  CartItem copyWith({
    String? itemId,
    String? nameAr,
    String? description,
    String? photoUrl,
    double? price,
    int? quantity,
    String? businessId,
  }) {
    return CartItem(
      itemId: itemId ?? this.itemId,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      businessId: businessId ?? this.businessId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'name_ar': nameAr,
      'description': description,
      'photo_url': photoUrl,
      'price': price,
      'quantity': quantity,
      'business_id': businessId,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    String asStringOrEmpty(dynamic value) => value?.toString() ?? '';

    double asDoubleOrZero(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int asIntOrZero(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return CartItem(
      itemId: asStringOrEmpty(json['item_id']),
      nameAr: asStringOrEmpty(json['name_ar']),
      description: asStringOrEmpty(json['description']),
      photoUrl: json['photo_url'] as String?,
      price: asDoubleOrZero(json['price']),
      quantity: asIntOrZero(json['quantity']),
      businessId: asStringOrEmpty(json['business_id']),
    );
  }
}