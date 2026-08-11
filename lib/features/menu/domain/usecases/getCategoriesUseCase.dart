import 'package:aklatna/features/menu/domain/entity/menuCategoryEntity.dart';
import 'package:aklatna/features/menu/domain/repository/menuRepo.dart';

class Getcategoriesusecase {
  final Menurepo repo;
  Getcategoriesusecase({required this.repo});

  Future<List<Menucategoryentity>> call() async {
    return await repo.getMenuCategories();
  }
}
