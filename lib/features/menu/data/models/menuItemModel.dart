class Menuitemmodel {
  final String id;
  final String businessId;
  final String categoryId;
  final String? name;
  final String nameAr;
  final String? description;
  final double price;
  final String? photoUrl;
  final bool isAvailable;
  final int sortOrder;
  Menuitemmodel({
    required this.id,
    required this.businessId,
    required this.categoryId,
    this.name,
    required this.nameAr,
    this.description,
    required this.price,
    this.photoUrl,
    required this.isAvailable,
    required this.sortOrder,
  });
  factory Menuitemmodel.fromSupabase(Map<String, dynamic> menuItem) {
    String asStringOrEmpty(dynamic value) => value?.toString() ?? '';

    bool asBoolOrFalse(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      final normalized = value?.toString().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
      return false;
    }

    double asDoubleOrZero(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int asIntOrZero(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return Menuitemmodel(
      id: asStringOrEmpty(menuItem['id']),
      businessId: asStringOrEmpty(menuItem['business_id']),
      categoryId: asStringOrEmpty(menuItem['category_id']),
      name: menuItem['name']?.toString(),
      nameAr: asStringOrEmpty(menuItem['name_ar']),
      description: menuItem['description']?.toString(),
      price: asDoubleOrZero(menuItem['price']),
      photoUrl: menuItem['photo_url']?.toString(),
      isAvailable: asBoolOrFalse(menuItem['is_available']),
      sortOrder: asIntOrZero(menuItem['sort_order']),
    );
  }
}
