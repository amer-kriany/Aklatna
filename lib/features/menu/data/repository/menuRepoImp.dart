import 'package:aklatna/features/menu/data/data_source/menuDataSource.dart';
import 'package:aklatna/features/menu/data/models/menuCategoryModel.dart';
import 'package:aklatna/features/menu/data/models/menuItemModel.dart';
import 'package:aklatna/features/menu/domain/entity/menuCategoryEntity.dart';
import 'package:aklatna/features/menu/domain/entity/menuItemEntity.dart';
import 'package:aklatna/features/menu/domain/repository/menuRepo.dart';

class Menurepoimp implements Menurepo {
  final Menudatasource menudatasource;
  Menurepoimp({required this.menudatasource});

  // get menu categories
  @override
  Future<List<Menucategoryentity>> getMenuCategories() async {
    final menuCategories = await menudatasource.getMenuCategories();
    return menuCategories.map((e)=>_mapToCategoryEntity(e)).toList() ;
  }
  // get menu items
  @override
  Future<List<Menuitementity>> getMenuItems() async {
    final menuItems = await menudatasource.getMenuItems();
    return menuItems.map((h)=>_mapToItemEntity(h)).toList() ;
  }

  Menucategoryentity _mapToCategoryEntity(Menucategorymodel model) {
    return Menucategoryentity(
      id: model.id,
      businessId: model.businessId,
      nameAr: model.nameAr,
      sortOrder: model.sortOrder,
      name: model.name,
    );
  }

  Menuitementity _mapToItemEntity(Menuitemmodel model) {
    return Menuitementity(
      id: model.id,
      businessId: model.businessId,
      categoryId: model.categoryId,
      nameAr: model.nameAr,
      name: model.name,
      description: model.description,
      photoUrl: model.photoUrl,
      price: model.price,
      isAvailable: model.isAvailable,
      sortOrder: model.sortOrder,
    );
  }
}
