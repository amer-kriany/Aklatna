import 'package:aklatna/core/utils/business_time_utils.dart';
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
  final String? createdAt;
  final String? ownerId;
  final double rating;
  final int ratingCount;
   bool get isOpen=> BusinessTimeUtils.isOpenNow(openingTime, closingTime)
   
   ;

  BusinessModel({
    required this.id,
    this.name,
    required this.nameAr,
    required this.phone,
    this.description,
    required this.openingTime,
    required this.closingTime,
    this.logoUrl,
    this.coverUrl,
    required this.adress,
    required this.type,
    this.createdAt,
    this.ownerId,
    required this.isActive,
    required this.rating,
    required this.ratingCount,
  });
  factory BusinessModel.fromSupabase(Map<String, dynamic> business) {
    return BusinessModel(
      id: business['id'],

      name: business['name'],
      nameAr: business['name_ar'],
      phone: business['phone'],
      openingTime: business['opening_time'],
      closingTime: business['closing_time'],
      logoUrl: business['logo_url'],
      adress: business['adress'],
      description: business['description'],
      createdAt: business['created_at'],
      ownerId: business['owner_user_id'],
      coverUrl: business['cover_url'],
      isActive: business['is_Active'],
      rating: business['rating'],
      ratingCount: business['rating_count'],
      type: BusinessType.values.byName(business['type']),
    );
  }
  
}
