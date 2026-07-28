import 'package:aklatna/features/review/domain/entity/reviewEntity.dart';
import 'package:aklatna/features/review/domain/usecase/submitReviewUsecase.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final SubmitReviewUsecase submitReviewUsecase;

  ReviewBloc({
    required this.submitReviewUsecase,
  }) : super(ReviewInitial()) {
    on<SubmitReviewEvent>(_submitReview);
  }

  // ============================================================
  // SUBMIT REVIEW
  // ============================================================

  Future<void> _submitReview(
    SubmitReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewSubmitting());

    try {
      await submitReviewUsecase(event.review);

      emit(ReviewSubmitted());
    } catch (e) {
      emit(ReviewError(message: e.toString()));
    }
  }
}