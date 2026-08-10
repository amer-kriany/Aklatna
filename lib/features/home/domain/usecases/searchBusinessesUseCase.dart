import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/home/domain/repository/businessRepo.dart';

class Searchbusinessesusecase {
  final Businessrepo businessrepo;
  Searchbusinessesusecase({required this.businessrepo});

  Future<List<BusinessEntity>> call({required String query}) async {
    return await businessrepo.searchBusinesses(query: query);
  }
}
