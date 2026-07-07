import 'package:aklatna/features/home/domain/entity/businessEntity.dart';

abstract class Businessrepo {
  // get business from supa
  Future<List<BusinessEntity>> getBusinessTable();
  // search businesses
  Future<List<BusinessEntity>> searchBusinesses({required String query});
}
