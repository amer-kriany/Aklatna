class PromotionEntity {
  final String id;
  final String label;
  final int discountPercentage;

  final String menuItemId;
  final String itemName;
  final String? photoUrl;
  final double? oldPrice;
  final double? newPrice;

  final String businessId;
  final String businessName;
  final bool isActive;

  const PromotionEntity({
    required this.id,
    required this.label,
    required this.discountPercentage,
    required this.menuItemId,
    required this.itemName,
    this.photoUrl,
    required this.businessId,
    required this.businessName,
    this.oldPrice,
    this.newPrice, required this.isActive,
  });
}
