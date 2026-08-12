part of 'promotions_bloc.dart';

sealed class PromotionsEvent extends Equatable {
  const PromotionsEvent();

  @override
  List<Object> get props => [];
}

class LoadPromotionsEvent extends PromotionsEvent {}
// event
class LoadPromotionsMapEvent extends PromotionsEvent {
  final String businessId;
  const LoadPromotionsMapEvent({required this.businessId});

  @override
  List<Object> get props => [businessId];
}

// state
class PromotionsMapLoaded extends PromotionsState {
  final Map<String, PromotionEntity> promotionsMap;
  const PromotionsMapLoaded({required this.promotionsMap});

  @override
  List<Object> get props => [promotionsMap];
}