import 'package:aklatna/features/home/data/models/businessModel.dart';
import 'package:aklatna/features/home/data/models/restaurantshourModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessDatasrouce {
  final supabase = Supabase.instance.client;

  // get business table form supa
  Future<List<BusinessModel>> getBusinesses() async {
    try {
      final business = await supabase.from("businesses").select();
      return business.map((e) => BusinessModel.fromSupabase(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // search by business
  Future<List<BusinessModel>> searchBusinesses({required String query}) async {
    try {final response = await supabase
        .from('businesses')
        .select()
        .eq('is_active', true)
        .ilike('name_ar', '%${query.trim()}%')
        .order('rating', ascending: false);
    return response.map((e) => BusinessModel.fromSupabase(e)).toList();} catch (e) {
      rethrow;
    }
    
  }

  // ============================================================
  // TODAY'S RESTAURANT HOURS (all businesses, single query)
  // ============================================================
  //
  // Fetches every business's hours row for today's day_of_week in one
  // request, rather than querying per-business (N+1). Merged client-side
  // against BusinessEntity by businessId in the repository layer.
  //
  // dayOfWeek convention: 0 = Monday ... 6 = Sunday (per dashboard).
  // Dart's DateTime.weekday is 1 = Monday ... 7 = Sunday, so callers
  // should pass (DateTime.now().weekday - 1).
  // ============================================================

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
}