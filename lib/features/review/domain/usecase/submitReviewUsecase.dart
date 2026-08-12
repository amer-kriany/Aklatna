import 'package:aklatna/features/review/domain/entity/reviewEntity.dart';
import 'package:aklatna/features/review/domain/repository/reviewRepository.dart';

class SubmitReviewUsecase {
  final ReviewRepository reviewRepositoryImpl;

  SubmitReviewUsecase({required this.reviewRepositoryImpl});

  Future<void> call(ReviewEntity review) {
    return reviewRepositoryImpl.submitReview(review);
  }
}