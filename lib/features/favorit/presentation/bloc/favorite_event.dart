part of 'favorite_bloc.dart';

sealed class FavoriteEvent extends Equatable {
  const FavoriteEvent();
  @override
  List<Object?> get props => [];
}

class LoadFavoritesEvent extends FavoriteEvent {
  final String userId;
  const LoadFavoritesEvent({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class ToggleFavoriteEvent extends FavoriteEvent {
  final String userId;
  final String businessId;
  const ToggleFavoriteEvent({required this.userId, required this.businessId});
  @override
  List<Object?> get props => [userId, businessId];
}