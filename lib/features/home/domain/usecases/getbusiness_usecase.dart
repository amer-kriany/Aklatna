import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/home/domain/repository/businessRepo.dart';

class GetbusinessUsecase {
  final Businessrepo repository;
  GetbusinessUsecase({required this.repository,});

  Future<List<BusinessEntity>> call() async {
    return await repository.getBusinessTable();
  }
}
