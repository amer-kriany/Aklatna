import 'package:aklatna/features/favorit/domain/useCases/favoriteUseCase.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/menu/domain/entity/menuItemEntity.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final AddFavoriteUsecase addFavoriteUsecase;
  final RemoveFavoriteUsecase removeFavoriteUsecase;
  final GetFavoriteIdsUsecase getFavoriteIdsUsecase;
  final GetFavoriteItemsUsecase getFavoriteItemsUsecase;

  FavoriteBloc({
    required this.addFavoriteUsecase,
    required this.removeFavoriteUsecase,
    required this.getFavoriteIdsUsecase,
    required this.getFavoriteItemsUsecase,
  }) : super(FavoriteInitial()) {
    on<LoadFavoritesEvent>(_onLoad);
    on<ToggleFavoriteEvent>(_onToggle);
  }

  Future<void> _onLoad(LoadFavoritesEvent event, Emitter<FavoriteState> emit) async {
    emit(FavoriteLoading());
    try {
      final businesses = await getFavoriteItemsUsecase(event.userId);
      final ids = await getFavoriteIdsUsecase(event.userId);
      emit(FavoriteLoaded(businesses: businesses, favoriteIds: ids.toSet()));
    } catch (e) {
      emit(FavoriteError(message: e.toString()));
    }
  }

  Future<void> _onToggle(ToggleFavoriteEvent event, Emitter<FavoriteState> emit) async {
    final current = state;
    if (current is! FavoriteLoaded) return; // must be loaded first

    final isFavorited = current.favoriteIds.contains(event.businessId);
    try {
      if (isFavorited) {
        await removeFavoriteUsecase(event.userId, event.businessId);
        final updatedIds = Set<String>.from(current.favoriteIds)..remove(event.businessId);
        final updatedItems = current.businesses.where((i) => i.id != event.businessId).toList();
        emit(FavoriteLoaded(businesses: updatedItems, favoriteIds: updatedIds));
      } else {
        await addFavoriteUsecase(event.userId, event.businessId);
        // Re-fetch to get the full item detail for the newly favorited item
        add(LoadFavoritesEvent(userId: event.userId));
      }
    } catch (e) {
      emit(FavoriteError(message: e.toString()));
    }
  }
}