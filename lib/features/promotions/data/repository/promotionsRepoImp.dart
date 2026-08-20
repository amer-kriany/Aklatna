import 'package:aklatna/features/promotions/data/dataSource/promotionDataSource.dart';
import 'package:aklatna/features/promotions/data/models/promotionModel.dart';
import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';
import 'package:aklatna/features/promotions/domain/repository/promotionsRepo.dart';

class Promotionsrepoimp implements Promotionsrepo {
  final Promotiondatasource promotiondatasource;
  Promotionsrepoimp({required this.promotiondatasource});

  @override
  Future<List<PromotionEntity>> getPromotions() async {
    final promotions = await promotiondatasource.getPromotions();
    return promotions.map((e) => mapToEntity(e)).toList();
  }

 @override
Future<Map<String, PromotionEntity>> getPromotionsMapForBusiness(String businessId) async {
  final all = await getPromotions();
  return {
    for (final p in all.where((p) => p.businessId == businessId && p.menuItemId != null))
      p.menuItemId!: p,
  };
}
}


PromotionEntity mapToEntity(Promotionmodel model) {
  return PromotionEntity(
    label: model.label,
    discountPercentage: model.discountPercentage,
    businessId: model.businessId,
    businessName: model.businessName,
    menuItemId: model.menuItemId,
    itemName: model.menuItemName,
    oldPrice: model.oldPrice,
    newPrice: model.newPrice,
    photoUrl: model.photoUrl,
    id: model.id,
    isActive: model.isActive,
    description: model.description,
    
    
  );
}
