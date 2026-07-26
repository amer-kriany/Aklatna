import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';
import 'package:aklatna/features/promotions/domain/repository/promotionsRepo.dart';

class GetPromotionsUseCase {
  final Promotionsrepo repo;

  GetPromotionsUseCase(this.repo);

  Future<List<PromotionEntity>> call() {
    return repo.getPromotions();
  }
}