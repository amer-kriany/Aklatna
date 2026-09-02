import 'package:aklatna/features/home/data/datasources/business_datasrouce.dart';
import 'package:aklatna/features/home/data/models/businessModel.dart';
import 'package:aklatna/features/home/data/models/restaurantshourModel.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/home/domain/repository/businessRepo.dart';

class Businessrepoimp implements Businessrepo {
  final BusinessDatasrouce businessDatasrouce;

  Businessrepoimp({
    required this.businessDatasrouce,
  });

  @override
  Future<List<BusinessEntity>> getBusinessTable() async {
    final business = await businessDatasrouce.getBusinesses();

    final hours = await _fetchTodayAndYesterdayHoursSafely();

    return business
        .map(
          (e) => mapToEntity(
            e,
            allHours: hours,
          ),
        )
        .toList();
  }

  @override
  Future<List<BusinessEntity>> searchBusinesses({
    required String query,
  }) async {
    final response = await businessDatasrouce.searchBusinesses(
      query: query,
    );

    final hours = await _fetchTodayAndYesterdayHoursSafely();

    return response
        .map(
          (e) => mapToEntity(
            e,
            allHours: hours,
          ),
        )
        .toList();
  }

  // ============================================================
  // TODAY + YESTERDAY'S HOURS
  // ============================================================

  Future<List<RestaurantHourModel>> _fetchTodayAndYesterdayHoursSafely() async {
    try {
      final todayIndex = DateTime.now().weekday - 1; // 0=Mon..6=Sun
      final hours = await businessDatasrouce.getTodayAndYesterdayHours(
        dayOfWeek: todayIndex,
      );
      return hours;
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // BUSINESS MODEL -> BUSINESS ENTITY
  // ============================================================

  BusinessEntity mapToEntity(
    BusinessModel model, {
    List<RestaurantHourModel> allHours = const [],
  }) {
    final todayIndex = DateTime.now().weekday - 1; // 0=Mon..6=Sun
    final yesterdayIndex = (todayIndex - 1 + 7) % 7;

    RestaurantHourModel? todayHours;
    RestaurantHourModel? yesterdayHours;

    for (final h in allHours) {
      if (h.businessId != model.id) continue;
      if (h.dayOfWeek == todayIndex) todayHours = h;
      if (h.dayOfWeek == yesterdayIndex) yesterdayHours = h;
    }

    final openingTime = todayHours?.openTime ?? model.openingTime;
    final closingTime = todayHours?.closeTime ?? model.closingTime;
    final isClosedToday = todayHours?.isClosed ?? false;

    return BusinessEntity(
      id: model.id,

      name: model.name,
      nameAr: model.nameAr,
      phone: model.phone,
      description: model.description,

      openingTime: openingTime,
      closingTime: closingTime,

      isClosedToday: isClosedToday,

      // NEW: yesterday's hours, needed for overnight spillover check.
      openingTimeYesterday: yesterdayHours?.openTime,
      closingTimeYesterday: yesterdayHours?.closeTime,
      isClosedYesterday: yesterdayHours?.isClosed ?? false,

      isActive: model.isActive,

      type: model.type,

      logoUrl: model.logoUrl,
      coverUrl: model.coverUrl,

      adress: model.adress,

      createdAt: model.createdAt,
      ownerId: model.ownerId,

      rating: model.rating,
      ratingCount: model.ratingCount,

      latitude: model.latitude,
      longitude: model.longitude,
    );
  }
}