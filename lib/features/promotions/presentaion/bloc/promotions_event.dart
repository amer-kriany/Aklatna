part of 'promotions_bloc.dart';

sealed class PromotionsEvent extends Equatable {
  const PromotionsEvent();

  @override
  List<Object> get props => [];
}

class LoadPromotionsEvent extends PromotionsEvent {}