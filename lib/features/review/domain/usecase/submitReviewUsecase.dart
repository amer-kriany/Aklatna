import 'package:aklatna/features/review/data/repository/reviewRepoImp.dart' ;
import 'package:aklatna/features/review/domain/entity/reviewEntity.dart';

class SubmitReviewUsecase {
  final ReviewRepositoryImpl reviewRepositoryImpl;

  SubmitReviewUsecase({required this.reviewRepositoryImpl});

  Future<void> call(ReviewEntity review) {
    return reviewRepositoryImpl.submitReview(review);
  }
}