import 'package:aklatna/features/promotions/data/models/promotionModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Promotiondatasource {
  final supabase = Supabase.instance.client;

  // get all promotions
 Future<List<Promotionmodel>> getPromotions() async {
 final response = await supabase
    .from('promotions')
    .select().eq('is_active', true);

  return response
      .map<Promotionmodel>((e) => Promotionmodel.fromJson(e))
      .toList();
}
}
