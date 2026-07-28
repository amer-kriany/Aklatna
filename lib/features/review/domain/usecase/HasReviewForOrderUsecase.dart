import 'package:aklatna/features/review/data/repository/reviewRepoImp.dart';

class HasReviewForOrderUsecase {
  final ReviewRepositoryImpl reviewRepositoryImpl;

  HasReviewForOrderUsecase({required this.reviewRepositoryImpl});

  Future<bool> call(String orderId) {
    return reviewRepositoryImpl.hasReviewForOrder(orderId);
  }
}