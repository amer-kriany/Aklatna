class ReviewEntity {
  final String? id;
  final String orderId;
  final String businessId;
  final String customerId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  ReviewEntity({
    this.id,
    required this.orderId,
    required this.businessId,
    required this.customerId,
    required this.rating,
    this.comment,
    this.createdAt,
  });
}