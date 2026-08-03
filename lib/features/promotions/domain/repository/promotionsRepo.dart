import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';

abstract class Promotionsrepo {
  // get all promotions
Future<List<PromotionEntity>> getPromotions();}
