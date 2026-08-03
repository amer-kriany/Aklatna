import 'package:aklatna/features/review/data/datasource/reviewRemoteDatasource.dart';
import 'package:aklatna/features/review/data/model/reviewModel.dart';
import 'package:aklatna/features/review/domain/entity/reviewEntity.dart';
import 'package:aklatna/features/review/domain/repository/reviewRepository.dart';


class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDatasource reviewRemoteDatasource;

  ReviewRepositoryImpl({required this.reviewRemoteDatasource});

  @override
  Future<void> submitReview(ReviewEntity review) async {
    await reviewRemoteDatasource.submitReview(mapEntityToModel(review));
  }

  @override
  Future<bool> hasReviewForOrder(String orderId) async {
    return reviewRemoteDatasource.hasReviewForOrder(orderId);
  }
}