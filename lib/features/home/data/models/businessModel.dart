import 'package:aklatna/features/home/business_type.dart';

class BusinessModel {
  final String id;
  final String? name;
  final String nameAr;
  final String phone;
  final String? description;
  final String openingTime;
  final String closingTime;
  final bool isActive;
  final BusinessType type;
  final String? logoUrl;
  final String? coverUrl;
  final String adress;

  BusinessModel({
    required this.id,
    this.name,
    required this.nameAr,
    required this.phone,
    this.description,
    required this.openingTime,
    required this.closingTime,
    required this.isActive,
    this.logoUrl,
    this.coverUrl,
    required this.adress, required this.type,
  });
  factory BusinessModel.fromSupabase(Map<String, dynamic> business) {
    return BusinessModel(
      id: business['id'],
      name: business['name'],
      nameAr: business['name_ar'],
      phone: business['phone'],
      openingTime: business['opening_time'],
      closingTime: business['closing_tiime'],
      isActive: business['is_active'],
      logoUrl: business['logo_url'],
      adress: business['adress'],
      description: business['description'],
      coverUrl: business['cover_url'], type: business['type'],
    );
  }
 
}
 