import 'package:aklatna/features/promotions/data/models/promotionModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Promotiondatasource {
  final supabase = Supabase.instance.client;

Future<List<Promotionmodel>> getPromotions() async {
  final response = await supabase
      .from('promotions')
      .select('*, businesses!inner(is_active)')
      .eq('is_active', true)
      .eq('businesses.is_active', true);

  return response
      .map<Promotionmodel>((e) => Promotionmodel.fromJson(e))
      .toList();
}
}
