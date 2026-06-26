class Menuitementity {
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
  Menuitementity({
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
}
