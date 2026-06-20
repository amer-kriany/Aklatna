import 'package:aklatna/features/home/data/models/businessModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessDatasrouce {
  final supabase = Supabase.instance.client;

  // get business table form supa
  Future<List<BusinessModel>> getBusinesses() async {
    try {
      final business = await supabase.from("businesses").select();
      return business.map((e)=>BusinessModel.fromSupabase(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
