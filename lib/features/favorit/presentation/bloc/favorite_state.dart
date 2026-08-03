part of 'favorite_bloc.dart';

sealed class FavoriteState extends Equatable {
  const FavoriteState();
  @override
  List<Object?> get props => [];
}

final class FavoriteInitial extends FavoriteState {}
final class FavoriteLoading extends FavoriteState {}

final class FavoriteLoaded extends FavoriteState {
  final List<BusinessEntity> businesses;
  final Set<String> favoriteIds;
  const FavoriteLoaded({required this.businesses, required this.favoriteIds});
  @override
  List<Object?> get props => [businesses, favoriteIds];
}

final class FavoriteError extends FavoriteState {
  final String message;
  const FavoriteError({required this.message});
  @override
  List<Object?> get props => [message];
}