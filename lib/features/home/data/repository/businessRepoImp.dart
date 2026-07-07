import 'package:aklatna/features/home/data/datasources/business_datasrouce.dart';
import 'package:aklatna/features/home/data/models/businessModel.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/home/domain/repository/businessRepo.dart';

class Businessrepoimp implements Businessrepo {
  final BusinessDatasrouce businessDatasrouce;
  Businessrepoimp({required this.businessDatasrouce});

  @override
  Future<List<BusinessEntity>> getBusinessTable() async {
    final business = await businessDatasrouce.getBusinesses();
    return business.map((e) => mapToEntity(e)).toList();
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
      rating: model.rating,
      ratingCount: model.ratingCount,
    );
  }

  @override
  Future<List<BusinessEntity>> searchBusinesses({required String query}) async {
    final response = await businessDatasrouce.searchBusinesses(query: query);
    return response.map((e)=>mapToEntity(e)).toList() ;
  }
}
