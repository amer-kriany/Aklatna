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

    final todayHours = await _fetchTodayHoursSafely();

    return business
        .map(
          (e) => mapToEntity(
            e,
            todayHours: todayHours,
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

    final todayHours = await _fetchTodayHoursSafely();

    return response
        .map(
          (e) => mapToEntity(
            e,
            todayHours: todayHours,
          ),
        )
        .toList();
  }

  // ============================================================
  // TODAY'S HOURS
  // ============================================================

Future<List<RestaurantHourModel>> _fetchTodayHoursSafely() async {
  try {
    final todayIndex = DateTime.now().weekday - 1;
    final hours = await businessDatasrouce.getTodayHours(dayOfWeek: todayIndex);
   
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
    List<RestaurantHourModel> todayHours = const [],
  }) {
    RestaurantHourModel? matchingHours;

    for (final hours in todayHours) {
      if (hours.businessId == model.id) {
        matchingHours = hours;
        break;
      }
    }

    final openingTime =
        matchingHours?.openTime ?? model.openingTime;

    final closingTime =
        matchingHours?.closeTime ?? model.closingTime;

    final isClosedToday =
        matchingHours?.isClosed ?? false;

    return BusinessEntity(
      id: model.id,

      name: model.name,
      nameAr: model.nameAr,
      phone: model.phone,
      description: model.description,

      openingTime: openingTime,
      closingTime: closingTime,

      isClosedToday: isClosedToday,

      isActive: model.isActive,

      type: model.type,

      logoUrl: model.logoUrl,
      coverUrl: model.coverUrl,

      adress: model.adress,

      createdAt: model.createdAt,
      ownerId: model.ownerId,

      rating: model.rating,
      ratingCount: model.ratingCount,

      // Restaurant coordinates
      latitude: model.latitude,
      longitude: model.longitude,
    );
  }
}