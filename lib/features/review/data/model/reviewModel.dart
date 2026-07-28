import 'package:aklatna/features/review/domain/entity/reviewEntity.dart';

class ReviewModel {
  final String? id;
  final String orderId;
  final String businessId;
  final String customerId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  ReviewModel({
    this.id,
    required this.orderId,
    required this.businessId,
    required this.customerId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  // order_id is bigint in Supabase, so it must be sent as an int,
  // not a string, even though we carry it as String in the entity
  // (matching how OrderEntity.id is also stored as String).
  Map<String, dynamic> toJson() {
    return {
      'order_id': int.parse(orderId),
      'business_id': businessId,
      'customer_id': customerId,
      'rating': rating,
      'comment': comment,
      // id, created_at — DB-generated, not sent from client
    };
  }

  factory ReviewModel.fromSupabase(Map<String, dynamic> review) {
    String asStringOrEmpty(dynamic value) => value?.toString() ?? '';
    String? asNullableString(dynamic value) => value?.toString();

    int asIntOrZero(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    DateTime? asNullableDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return ReviewModel(
      id: asStringOrEmpty(review['id']),
      orderId: asStringOrEmpty(review['order_id']),
      businessId: asStringOrEmpty(review['business_id']),
      customerId: asStringOrEmpty(review['customer_id']),
      rating: asIntOrZero(review['rating']),
      comment: asNullableString(review['comment']),
      createdAt: asNullableDate(review['created_at']),
    );
  }
}

ReviewEntity mapModelToEntity(ReviewModel model) {
  return ReviewEntity(
    id: model.id,
    orderId: model.orderId,
    businessId: model.businessId,
    customerId: model.customerId,
    rating: model.rating,
    comment: model.comment,
    createdAt: model.createdAt,
  );
}

ReviewModel mapEntityToModel(ReviewEntity entity) {
  return ReviewModel(
    id: entity.id,
    orderId: entity.orderId,
    businessId: entity.businessId,
    customerId: entity.customerId,
    rating: entity.rating,
    comment: entity.comment,
    createdAt: entity.createdAt,
  );
}