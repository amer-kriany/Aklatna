class Promotionmodel {
  final String id;
  final String? label;
  final int discountPercentage;

  final String businessId;
  final String businessName;

  final String? menuItemId;
  final String menuItemName;

  final String? photoUrl;
  final double? oldPrice;
  final double? newPrice;
  final bool isActive;
  final String? description;

  final DateTime createdAt;

  const Promotionmodel({
    required this.id,
    this.label,
    required this.discountPercentage,
    required this.businessId,
    required this.businessName,
    this.menuItemId,
    required this.menuItemName,
    this.photoUrl,
    required this.createdAt,
    this.oldPrice,
    this.newPrice,
    required this.isActive, this.description,
  });

  factory Promotionmodel.fromJson(Map<String, dynamic> json) {
    String asStringOrEmpty(dynamic value) => value?.toString() ?? '';
    String? asNullableString(dynamic value) => value?.toString();
    double? asNullableDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int asIntOrZero(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    DateTime asDateOrEpoch(dynamic value) {
      if (value is DateTime) return value;
      return DateTime.tryParse(value?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Promotionmodel(
      id: asStringOrEmpty(json['id']),
      label: asNullableString(json['label']),
      discountPercentage: asIntOrZero(json['discount_percentage']),

      businessId: asStringOrEmpty(json['business_id']),
      businessName: asStringOrEmpty(json['business_name']),

      menuItemId: asNullableString(json['menu_item_id']),
      menuItemName: asStringOrEmpty(json['menu_item_name']),

      photoUrl: asNullableString(json['photo_url']),

      createdAt: asDateOrEpoch(json['created_at']),
      isActive: json['is_active'] ?? false,
      oldPrice: asNullableDouble(json['old_price']),
      newPrice: asNullableDouble(json['new_price']),
      description: asNullableString(json['description']),
    );
  }
}
