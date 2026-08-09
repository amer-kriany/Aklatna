part of 'promotions_bloc.dart';

sealed class PromotionsState extends Equatable {
  const PromotionsState();

  @override
  List<Object> get props => [];
}

final class PromotionsInitial extends PromotionsState {}

final class PromotionsLoading extends PromotionsState {}

final class PromotionsLoaded extends PromotionsState {
  final List<PromotionEntity> promotions;

  const PromotionsLoaded({
    required this.promotions,
  });

  @override
  List<Object> get props => [promotions];
}

final class PromotionsError extends PromotionsState {
  final String message;

  const PromotionsError({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}