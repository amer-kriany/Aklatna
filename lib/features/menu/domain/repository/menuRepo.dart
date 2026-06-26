import 'package:aklatna/features/menu/domain/entity/menuCategoryEntity.dart';
import 'package:aklatna/features/menu/domain/entity/menuItemEntity.dart';

abstract class Menurepo {
  Future<List<Menucategoryentity>> getMenuCategories();
  Future<List<Menuitementity>> getMenuItems();
}
