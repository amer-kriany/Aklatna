import 'package:aklatna/features/menu/data/repository/menuRepoImp.dart';
import 'package:aklatna/features/menu/domain/entity/menuItemEntity.dart';

class Getitemsusecase {
  final Menurepoimp repo;
  Getitemsusecase({required this.repo});

  // get menu items
  Future<List<Menuitementity>> call() async {
    return await repo.getMenuItems();
  }
}
