import 'package:aklatna/features/review/domain/repository/reviewRepository.dart';

class HasReviewForOrderUsecase {
  final ReviewRepository reviewRepositoryImpl;

  HasReviewForOrderUsecase({required this.reviewRepositoryImpl});

  Future<bool> call(String orderId) {
    return reviewRepositoryImpl.hasReviewForOrder(orderId);
  }
}