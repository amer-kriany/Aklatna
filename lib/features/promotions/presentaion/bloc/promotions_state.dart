part of 'promotions_bloc.dart';

sealed class PromotionsState extends Equatable {
  const PromotionsState();
  
  @override
  List<Object> get props => [];
}

final class PromotionsInitial extends PromotionsState {}
