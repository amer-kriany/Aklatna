import 'package:aklatna/features/promotions/data/dataSource/promotionDataSource.dart';
import 'package:aklatna/features/promotions/data/models/promotionModel.dart';
import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';
import 'package:aklatna/features/promotions/domain/repository/promotionsRepo.dart';

class Promotionsrepoimp implements Promotionsrepo {
  final Promotiondatasource promotiondatasource;
  Promotionsrepoimp({required this.promotiondatasource});

  // get all promotions
  @override
  Future<List<Promotionentity>> getAllPromotions() async {
    final promotions = await promotiondatasource.getAllPromotions();
    return  promotions.map((e)=>mapToEntity(e)).toList() ;
  }
}

Promotionentity mapToEntity(Promotionmodel model) {
  return Promotionentity(
    id: model.id,
    label: model.label,
    discountPercentage: model.discountPercentage,
    businessId: model.businessId,
    startTime: model.startTime,
    endTime: model.endTime, createdAt: model.createdAt,
  );
}
