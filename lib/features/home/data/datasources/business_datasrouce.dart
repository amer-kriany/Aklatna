import 'package:aklatna/features/home/data/models/businessModel.dart';
import 'package:aklatna/features/home/data/models/restaurantshourModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessDatasrouce {
  final supabase = Supabase.instance.client;

  Future<List<BusinessModel>> getBusinesses() async {
    try {
      final business = await supabase
          .from("businesses")
          .select()
          .eq('is_active', true);
      return business.map((e) => BusinessModel.fromSupabase(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BusinessModel>> searchBusinesses({required String query}) async {
    try {
      final response = await supabase
          .from('businesses')
          .select()
          .eq('is_active', true)
          .ilike('name_ar', '%${query.trim()}%')
          .order('rating', ascending: false);
      return response.map((e) => BusinessModel.fromSupabase(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // TODAY'S RESTAURANT HOURS (all businesses, single query)
  // ============================================================
  // Kept for backward compatibility if referenced elsewhere.
  Future<List<RestaurantHourModel>> getTodayHours({
    required int dayOfWeek,
  }) async {
    try {
      final response = await supabase
          .from('restaurant_hours')
          .select()
          .eq('day_of_week', dayOfWeek);

      return response
          .map((e) => RestaurantHourModel.fromSupabase(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // TODAY + YESTERDAY'S RESTAURANT HOURS (all businesses, single query)
  // ============================================================
  //
  // Needed to correctly detect overnight hours (e.g. Wed 09:00->03:00)
  // that are still "open" after midnight has rolled into Thursday.
  //
  // dayOfWeek convention: 0 = Monday ... 6 = Sunday (per dashboard).
  // ============================================================

  Future<List<RestaurantHourModel>> getTodayAndYesterdayHours({
    required int dayOfWeek,
  }) async {
    try {
      final yesterday = (dayOfWeek - 1 + 7) % 7;
      final response = await supabase
          .from('restaurant_hours')
          .select()
          .inFilter('day_of_week', [dayOfWeek, yesterday]);

      return response
          .map((e) => RestaurantHourModel.fromSupabase(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}