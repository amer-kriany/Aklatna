import 'package:aklatna/features/home/data/repository/businessRepoImp.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';

class Searchbusinessesusecase {
  final Businessrepoimp businessrepoimp;
  Searchbusinessesusecase({required this.businessrepoimp});

  Future<List<BusinessEntity>> call({required String query}) async {
    return await businessrepoimp.searchBusinesses(query: query);
  }
}
