import 'package:aklatna/features/promotions/data/models/promotionModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Promotiondatasource {
  final supabase = Supabase.instance.client;

  // get all promotions
  Future<List<Promotionmodel>> getAllPromotions() async {
    try {
      final response = await supabase.from('promotions').select();
      return response.map((e)=>Promotionmodel.fromJson(e)).toList() ; 
    } catch (e) {
      rethrow;
    }
  }
}
