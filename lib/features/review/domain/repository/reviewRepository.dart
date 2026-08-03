import 'package:aklatna/features/review/domain/entity/reviewEntity.dart';

abstract class ReviewRepository {
  Future<void> submitReview(ReviewEntity review);
  Future<bool> hasReviewForOrder(String orderId);
}