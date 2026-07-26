import 'package:aklatna/features/addOnes/data/model/addOnesModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Addonesdatasource {
  final supabase = Supabase.instance.client;

  Future<List<AddonModel>> getAddonsForItem(String itemId) async {
  try {
    final response = await supabase.from('product_addons').select().eq('item_id', itemId);
    return response.map((e) => AddonModel.fromJson(e)).toList();
  } catch (e) {
    rethrow;
  }
}
}
