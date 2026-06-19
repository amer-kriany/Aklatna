import 'package:aklatna/features/home/data/datasources/business_datasrouce.dart';
import 'package:aklatna/features/home/data/models/businessModel.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';

class Businessrepoimp {
  final BusinessDatasrouce businessDatasrouce;
  Businessrepoimp({required this.businessDatasrouce});

  Future<BusinessEntity> getBusinessTable() async {
    final business = await businessDatasrouce.getBusinesses();
    return mapToEntity(business);
  }

  mapToEntity(Businessmodel model) {
    return BusinessEntity(
      id: model.id,
      nameAr: model.nameAr,
      phone: model.phone,
      openingTime: model.openingTime,
      closingTime: model.closingTime,
      isActive: model.isActive,
      logoUrl: model.logoUrl,
      adress: model.adress,
      type: model.type,
    );
  }
}
