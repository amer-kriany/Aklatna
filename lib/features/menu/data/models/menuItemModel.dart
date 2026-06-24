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
    return Menuitemmodel(
      id: menuItem['id'],
      businessId: menuItem['business_id'],
      categoryId: menuItem['category_id'],
      nameAr: menuItem['name_ar'],
      price: menuItem['price'],
      isAvailable: menuItem['is_available'],
      sortOrder: menuItem['sort_order'],
    );
    
  }
}
