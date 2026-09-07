import 'package:aklatna/core/utils/business_time_utils.dart';
import 'package:aklatna/features/home/business_type.dart';

class BusinessEntity {
  final String id;

  final String? name;

  final String nameAr;

  final String phone;

  final String? description;

  // ============================================================
  // BUSINESS HOURS
  // ============================================================

  final String openingTime;

  final String closingTime;

  final bool isClosedToday;

  // Yesterday's hours — needed to detect overnight windows (e.g.
  // Wed 09:00->03:00) that are still open after midnight rolls into today.
  final String? openingTimeYesterday;

  final String? closingTimeYesterday;

  final bool isClosedYesterday;

  // ============================================================
  // BUSINESS
  // ============================================================

  final bool isActive;

  final BusinessType type;

  final String? logoUrl;

  final String? coverUrl;

  final String adress;

  final String createdAt;

  final String? ownerId;

  // ============================================================
  // RATING
  // ============================================================

  final double rating;

  final int ratingCount;

  // ============================================================
  // LOCATION
  // ============================================================

  final double? latitude;

  final double? longitude;

  // ============================================================
  // OPEN STATUS
  // ============================================================

  bool get isOpen {
    if (!isActive) {
      return false;
    }

    final hasYesterdayHours =
        openingTimeYesterday != null && closingTimeYesterday != null;

    return BusinessTimeUtils.isOpenNowWithOvernightCheck(
      todayActive: !isClosedToday,
      todayOpen: openingTime,
      todayClose: closingTime,
      yesterdayActive: hasYesterdayHours && !isClosedYesterday,
      yesterdayOpen: openingTimeYesterday ?? '00:00',
      yesterdayClose: closingTimeYesterday ?? '00:00',
    );
  }

  BusinessEntity({
    required this.id,
    this.name,
    required this.nameAr,
    required this.phone,
    this.description,

    // Business hours
    required this.openingTime,
    required this.closingTime,
    this.isClosedToday = false,
    this.openingTimeYesterday,
    this.closingTimeYesterday,
    this.isClosedYesterday = false,

    // Business
    required this.isActive,
    required this.type,
    this.logoUrl,
    this.coverUrl,
    required this.adress,
    required this.createdAt,
    this.ownerId,

    // Rating
    required this.rating,
    required this.ratingCount,

    // Location
    this.latitude,
    this.longitude,
  });
}