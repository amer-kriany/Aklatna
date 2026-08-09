part of 'promotions_bloc.dart';

sealed class PromotionsState extends Equatable {
  const PromotionsState();

  @override
  List<Object> get props => [];
}

class PromotionsInitial extends PromotionsState {}

class PromotionsLoading extends PromotionsState {}

class PromotionsLoaded extends PromotionsState {
  final List<PromotionEntity> promotions;
  const PromotionsLoaded({required this.promotions});

  @override
  List<Object> get props => [promotions];
}

class PromotionsError extends PromotionsState {
  final String message;
  const PromotionsError({required this.message});

  @override
  List<Object> get props => [message];
}