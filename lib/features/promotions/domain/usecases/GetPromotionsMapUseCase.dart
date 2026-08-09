import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';
import 'package:aklatna/features/promotions/domain/repository/promotionsRepo.dart';

class GetPromotionsMapUseCase {
  final Promotionsrepo repo;
  GetPromotionsMapUseCase({required this.repo});

  Future<Map<String, PromotionEntity>> call(String businessId) {
    return repo.getPromotionsMapForBusiness(businessId);
  }
}