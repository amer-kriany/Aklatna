import 'package:aklatna/features/home/data/models/businessModel.dart';
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
}
