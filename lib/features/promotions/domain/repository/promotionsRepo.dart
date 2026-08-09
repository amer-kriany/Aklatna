import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';

abstract class Promotionsrepo {
  // get all promotions
Future<List<PromotionEntity>> getPromotions();
  Future<Map<String, PromotionEntity>> getPromotionsMapForBusiness(String businessId);
}
