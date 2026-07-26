import 'package:aklatna/features/addOnes/domain/enitity/addOnesEntity.dart';
import 'package:aklatna/features/addOnes/domain/repository/addOnesRepo.dart';

class GetAddonsUsecase {
  final AddonRepository repo;
  GetAddonsUsecase({required this.repo});

  Future<List<AddonEntity>> call(String itemId) => repo.getAddonsForItem(itemId);
}