import 'package:aklatna/features/promotions/data/repository/promotionsRepoImp.dart';
import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';

class Promotionsusecase {
  final Promotionsrepoimp promotionsrepoimp;
  Promotionsusecase({required this.promotionsrepoimp});

  // get all promotions
  Future<List<Promotionentity>> call() async {
    return await promotionsrepoimp.getAllPromotions() ;
  }
}
