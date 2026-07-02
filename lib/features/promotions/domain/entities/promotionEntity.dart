class Promotionentity {
  final String id;
  final String label;
  final int discountPercentage;
  final String businessId;
  final String? imageUrl;
final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  const Promotionentity({
    required this.id,
    required this.label,
    required this.discountPercentage,
    required this.businessId,
    required this.startTime,
    required this.endTime,
    this.imageUrl, required this.createdAt,
  });
}
