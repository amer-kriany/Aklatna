import 'package:aklatna/features/home/data/datasources/business_datasrouce.dart';
import 'package:aklatna/features/home/data/models/businessModel.dart';
import 'package:aklatna/features/home/data/models/restaurantshourModel.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/home/domain/repository/businessRepo.dart';

class Businessrepoimp implements Businessrepo {
  final BusinessDatasrouce businessDatasrouce;
  Businessrepoimp({required this.businessDatasrouce});

  @override
  Future<List<BusinessEntity>> getBusinessTable() async {
    final business = await businessDatasrouce.getBusinesses();
    final todayHours = await _fetchTodayHoursSafely();

    return business
        .map((e) => mapToEntity(e, todayHours: todayHours))
        .toList();
  }

  @override
  Future<List<BusinessEntity>> searchBusinesses({required String query}) async {
    final response = await businessDatasrouce.searchBusinesses(query: query);
    final todayHours = await _fetchTodayHoursSafely();

    return response
        .map((e) => mapToEntity(e, todayHours: todayHours))
        .toList();
  }

  // ============================================================
  // TODAY'S HOURS FETCH
  // ============================================================
  //
  // Wrapped in its own try/catch so that if restaurant_hours is
  // unreachable for any reason, business listing still works —
  // it just falls back to the old businesses.opening_time/closing_time
  // columns for every business, instead of crashing the whole page.
  // ============================================================

  Future<List<RestaurantHourModel>> _fetchTodayHoursSafely() async {
    try {
      // Dart's DateTime.weekday is 1=Monday..7=Sunday.
      // Dashboard's day_of_week is 0=Monday..6=Sunday.
      final todayIndex = DateTime.now().weekday - 1;

      return await businessDatasrouce.getTodayHours(dayOfWeek: todayIndex);
    } catch (e) {
      return [];
    }
  }

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

    // Fallback: if this business has no restaurant_hours row for today
    // yet (e.g. the restaurant owner hasn't set weekly hours via the
    // dashboard), use the old single opening_time/closing_time columns
    // on businesses so the app doesn't show it as closed by default.
    final openingTime = matchingHours?.openTime ?? model.openingTime;
    final closingTime = matchingHours?.closeTime ?? model.closingTime;
    final isClosedToday = matchingHours?.isClosed ?? false;

    return BusinessEntity(
      id: model.id,
      name: model.name,
      nameAr: model.nameAr,
      phone: model.phone,
      openingTime: openingTime,
      closingTime: closingTime,
      isClosedToday: isClosedToday,
      isActive: model.isActive,
      logoUrl: model.logoUrl,
      adress: model.adress,
      type: model.type,
      rating: model.rating,
      ratingCount: model.ratingCount,
      coverUrl: model.coverUrl,
    );
  }
}