part of 'review_bloc.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class SubmitReviewEvent extends ReviewEvent {
  final ReviewEntity review;

  const SubmitReviewEvent({required this.review});

  @override
  List<Object?> get props => [review];
}