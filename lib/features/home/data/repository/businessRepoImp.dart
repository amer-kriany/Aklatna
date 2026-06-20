import 'package:aklatna/features/home/data/datasources/business_datasrouce.dart';
import 'package:aklatna/features/home/data/models/businessModel.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';

class Businessrepoimp {
  final BusinessDatasrouce businessDatasrouce;
  Businessrepoimp({required this.businessDatasrouce});

  Future<List<BusinessEntity>> getBusinessTable() async {
    final business = await businessDatasrouce.getBusinesses();
    return business.map((e)=>mapToEntity(e)).toList();
  }

  
 BusinessEntity mapToEntity(BusinessModel model) {
    return BusinessEntity(
      id: model.id,
      name: model.name,
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
