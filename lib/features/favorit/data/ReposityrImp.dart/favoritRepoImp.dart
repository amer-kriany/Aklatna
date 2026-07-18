import 'package:aklatna/features/favorit/data/datasource/favoriteDataSource.dart';
import 'package:aklatna/features/favorit/domain/repository/favoritRepository.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/menu/domain/entity/menuItemEntity.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteDatasource datasource;
  FavoriteRepositoryImpl({required this.datasource});

  @override
  Future<void> addFavorite(String userId, String businessId) =>
      datasource.addFavorite(userId, businessId);

  @override
  Future<void> removeFavorite(String userId, String businessId) =>
      datasource.removeFavorite(userId, businessId);

  @override
  Future<List<String>> getFavoriteIds(String userId) =>
      datasource.getFavoriteIds(userId);

  @override
  Future<List<BusinessEntity>> getFavoriteBusinesses(String userId) async {
    final models = await datasource.getFavoriteBusinesses(userId);
    return models
        .map(
          (model) => BusinessEntity(
            id: model.id,
            nameAr: model.nameAr,
            phone: model.phone,
            openingTime: model.openingTime,
            closingTime: model.closingTime,
            isActive: model.isActive,
            adress: model.adress,
            type: model.type,
            rating: model.rating,
            ratingCount: model.ratingCount,
          ),
        )
        .toList();
  }
}
