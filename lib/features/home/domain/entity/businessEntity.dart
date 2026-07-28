import 'package:aklatna/core/utils/business_time_utils.dart';
import 'package:aklatna/features/home/business_type.dart';

class BusinessEntity {
  final String id;
  final String? name;
  final String nameAr;
  final String phone;
  final String? description;

  final String openingTime;
  final String closingTime;

  final bool isClosedToday;
  final bool isActive;

  final BusinessType type;

  final String? logoUrl;
  final String? coverUrl;

  final String adress;

  final String? createdAt;
  final String? ownerId;

  final double rating;
  final int ratingCount;

  // Restaurant location
  final double? latitude;
  final double? longitude;

  bool get isOpen {
    if (isClosedToday) return false;

    return BusinessTimeUtils.isOpenNow(
      openingTime,
      closingTime,
    );
  }

  BusinessEntity({
    required this.id,
    this.name,
    required this.nameAr,
    required this.phone,
    this.description,

    required this.openingTime,
    required this.closingTime,

    this.isClosedToday = false,
    required this.isActive,

    required this.type,

    this.logoUrl,
    this.coverUrl,

    required this.adress,

    this.createdAt,
    this.ownerId,

    required this.rating,
    required this.ratingCount,

    // Nullable because old businesses may not have coordinates yet.
    this.latitude,
    this.longitude,
  });
}