import 'package:aklatna/features/home/data/models/businessModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessDatasrouce {
  final supabase = Supabase.instance.client;

  // get business table form supa
  Future<Businessmodel> getBusinesses() async {
    try {
      final business = await supabase.from("businesses").select().single();
      return Businessmodel.fromSupabase(business) ;
    } catch (e) {
      rethrow;
    }
  }
}
