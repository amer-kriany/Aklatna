import 'package:aklatna/features/home/businessType.dart';

class BusinessEntity {
  final String id;
  final String? name;
  final String nameAr;
  final String phone;
  final String? description;
  final String openingTime;
  final String closingTime;
  final bool isActive;
  final BusinessType type;
  final String logoUrl;
  final String? coverUrl;
  final String adress;

  BusinessEntity({
    required this.id,
    this.name,
    required this.nameAr,
    required this.phone,
    this.description,
    required this.openingTime,
    required this.closingTime,
    required this.isActive,
    required this.logoUrl,
    this.coverUrl,
    required this.adress,
    required this.type,
  });
}
