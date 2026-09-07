class CartItem {
  final String itemId;
  final String nameAr;
  final String description;
  final String? photoUrl;
  final double price;
  final int quantity;
  final String businessId;
  final String note;
  final List<Map<String, dynamic>> selectedAddons;

  CartItem({
    required this.itemId,
    required this.nameAr,
    required this.description,
    this.photoUrl,
    required this.price,
    required this.quantity,
    required this.businessId,
    this.note = '',
    this.selectedAddons = const [],
  });

  CartItem copyWith({
    String? itemId,
    String? nameAr,
    String? description,
    String? photoUrl,
    double? price,
    int? quantity,
    String? businessId,
    String? note,
    List<Map<String, dynamic>>? selectedAddons,
  }) {
    return CartItem(
      itemId: itemId ?? this.itemId,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      businessId: businessId ?? this.businessId,
      note: note ?? this.note,
      selectedAddons: selectedAddons ?? this.selectedAddons,
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
    'note': note,
    'addons': selectedAddons,
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

    List<Map<String, dynamic>> asAddonsOrEmpty(dynamic value) {
      if (value is! List) return [];
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return CartItem(
      itemId: asStringOrEmpty(json['item_id']),
      nameAr: asStringOrEmpty(json['name_ar']),
      description: asStringOrEmpty(json['description']),
      photoUrl: json['photo_url'] as String?,
      price: asDoubleOrZero(json['price']),
      quantity: asIntOrZero(json['quantity']),
      businessId: asStringOrEmpty(json['business_id']),
      note: asStringOrEmpty(json['note']),
      selectedAddons: asAddonsOrEmpty(json['addons']),
    );
  }
}
