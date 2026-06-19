import 'package:aklatna/features/home/data/repository/businessRepoImp.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';

class GetbusinessUsecase {
  final Businessrepoimp businessrepoimp;
  GetbusinessUsecase({required this.businessrepoimp});

  Future<BusinessEntity> call() async {
    return await businessrepoimp.getBusinessTable();
  }
}
