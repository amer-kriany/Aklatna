import 'package:aklatna/features/home/data/repository/businessRepoImp.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';

class GetbusinessUsecase {
  final Businessrepoimp repository;
  GetbusinessUsecase({required this.repository,});

  Future<List<BusinessEntity>> call() async {
    return await repository.getBusinessTable();
  }
}
