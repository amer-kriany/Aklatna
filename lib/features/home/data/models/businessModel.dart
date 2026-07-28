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

  // Restaurant location
  final double? latitude;
  final double? longitude;

  final double rating;
  final int ratingCount;
  final DateTime expiresAt;
  final DateTime? renewalRequestedAt;

  bool get isOpen =>
      BusinessTimeUtils.isOpenNow(openingTime, closingTime);

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
    required this.expiresAt,
    required this.renewalRequestedAt,

    // Location
    this.latitude,
    this.longitude,
  });

  factory BusinessModel.fromSupabase(
    Map<String, dynamic> business,
  ) {
    String asStringOrEmpty(dynamic value) {
      return value?.toString() ?? '';
    }

    String? asNullableString(dynamic value) {
      return value?.toString();
    }

    bool asBoolOrFalse(dynamic value) {
      if (value is bool) return value;

      if (value is num) {
        return value != 0;
      }

      final normalized = value?.toString().toLowerCase();

      if (normalized == 'true' || normalized == '1') {
        return true;
      }

      if (normalized == 'false' || normalized == '0') {
        return false;
      }

      return false;
    }

    double asDoubleOrZero(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }

      return double.tryParse(
            value?.toString() ?? '',
          ) ??
          0;
    }

    double? asNullableDouble(dynamic value) {
      if (value == null) return null;

      if (value is num) {
        return value.toDouble();
      }

      return double.tryParse(
        value.toString(),
      );
    }

    int asIntOrZero(dynamic value) {
      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(
            value?.toString() ?? '',
          ) ??
          0;
    }

    DateTime asDateOrEpoch(dynamic value) {
      if (value is DateTime) {
        return value;
      }

      return DateTime.tryParse(
            value?.toString() ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    DateTime? asDateOrNull(dynamic value) {
      if (value == null) return null;

      if (value is DateTime) {
        return value;
      }

      return DateTime.tryParse(
        value.toString(),
      );
    }

    BusinessType asBusinessType(dynamic value) {
      final normalized = value?.toString();

      if (normalized == null) {
        return BusinessType.restaurant;
      }

      return BusinessType.values.firstWhere(
        (type) => type.name == normalized,
        orElse: () => BusinessType.restaurant,
      );
    }

    return BusinessModel(
      id: asStringOrEmpty(
        business['id'],
      ),

      name: asNullableString(
        business['name'],
      ),

      nameAr: asStringOrEmpty(
        business['name_ar'],
      ),

      phone: asStringOrEmpty(
        business['phone'],
      ),

      openingTime: asStringOrEmpty(
        business['opening_time'],
      ),

      closingTime: asStringOrEmpty(
        business['closing_time'],
      ),

      logoUrl: asNullableString(
        business['logo_url'],
      ),

      adress: asStringOrEmpty(
        business['adress'] ?? business['address'],
      ),

      description: asNullableString(
        business['description'],
      ),

      createdAt: asNullableString(
        business['created_at'],
      ),

      ownerId: asNullableString(
        business['owner_user_id'],
      ),

      coverUrl: asNullableString(
        business['cover_url'],
      ),

      isActive: asBoolOrFalse(
        business['is_active'],
      ),

      rating: asDoubleOrZero(
        business['rating'],
      ),

      ratingCount: asIntOrZero(
        business['rating_count'],
      ),

      type: asBusinessType(
        business['type'],
      ),

      expiresAt: asDateOrEpoch(
        business['expires_at'],
      ),

      renewalRequestedAt: asDateOrNull(
        business['renewal_requested_at'],
      ),

      // Restaurant coordinates from Supabase
      latitude: asNullableDouble(
        business['latitude'],
      ),

      longitude: asNullableDouble(
        business['longitude'],
      ),
    );
  }
}