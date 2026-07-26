import 'package:aklatna/features/promotions/data/dataSource/promotionDataSource.dart';
import 'package:aklatna/features/promotions/data/models/promotionModel.dart';
import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';
import 'package:aklatna/features/promotions/domain/repository/promotionsRepo.dart';

class Promotionsrepoimp implements Promotionsrepo {
  final Promotiondatasource promotiondatasource;
  Promotionsrepoimp({required this.promotiondatasource});

  // get all promotions
  @override
  Future<List<PromotionEntity>> getPromotions() async {
    final promotions = await promotiondatasource.getPromotions();
    return promotions.map((e) => mapToEntity(e)).toList();
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
    photoUrl: model.photoUrl ?? '',
    id: model.id,
    isActive: model.isActive,
  );
}
