import 'package:aklatna/features/menu/domain/entity/menuItemEntity.dart';
import 'package:aklatna/features/menu/domain/repository/menuRepo.dart';

class Getitemsusecase {
  final Menurepo repo;
  Getitemsusecase({required this.repo});

  // get menu items
  Future<List<Menuitementity>> call() async {
    return await repo.getMenuItems();
  }
}
