import 'package:aklatna/features/menu/data/repository/menuRepoImp.dart';
import 'package:aklatna/features/menu/domain/entity/menuCategoryEntity.dart';

class Getcategoriesusecase {
  final Menurepoimp repo;
  Getcategoriesusecase({required this.repo});

  Future<List<Menucategoryentity>> call() async {
    return await repo.getMenuCategories();
  }
}
