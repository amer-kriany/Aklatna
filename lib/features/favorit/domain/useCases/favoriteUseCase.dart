import 'package:aklatna/features/favorit/domain/repository/favoritRepository.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';

class AddFavoriteUsecase {
  final FavoriteRepository repo;
  AddFavoriteUsecase({required this.repo});
  Future<void> call(String userId, String menuItemId) => repo.addFavorite(userId, menuItemId);
}

class RemoveFavoriteUsecase {
  final FavoriteRepository repo;
  RemoveFavoriteUsecase({required this.repo});
  Future<void> call(String userId, String menuItemId) => repo.removeFavorite(userId, menuItemId);
}

class GetFavoriteIdsUsecase {
  final FavoriteRepository repo;
  GetFavoriteIdsUsecase({required this.repo});
  Future<List<String>> call(String userId) => repo.getFavoriteIds(userId);
}

class GetFavoriteItemsUsecase {
  final FavoriteRepository repo;
  GetFavoriteItemsUsecase({required this.repo});
  Future<List<BusinessEntity>> call(String userId) => repo.getFavoriteBusinesses(userId);
}