import 'package:aklatna/features/home/domain/entity/businessEntity.dart';

abstract class Businessrepo {
  // get business from supa
  Future<BusinessEntity> getBusinessTable();
}
