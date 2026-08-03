import 'package:aklatna/features/home/domain/entity/businessEntity.dart';

abstract class FavoriteRepository {
  Future<void> addFavorite(String userId, String menuItemId);
  Future<void> removeFavorite(String userId, String menuItemId);
  Future<List<String>> getFavoriteIds(String userId);
  Future<List<BusinessEntity>> getFavoriteBusinesses(String userId);
}