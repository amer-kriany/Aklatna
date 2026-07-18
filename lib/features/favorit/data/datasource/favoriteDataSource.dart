import 'package:aklatna/features/home/data/models/businessModel.dart';
import 'package:aklatna/features/menu/data/models/menuItemModel.dart'; // adjust import to your real path
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteDatasource {
  final supabase = Supabase.instance.client;

  Future<void> addFavorite(String userId, String businessId) async {
  try {
    await supabase.from('favorites').insert({
      'user_id': userId,
      'business_id': businessId,
    });
  } catch (e) {
    rethrow;
  }
}

Future<void> removeFavorite(String userId, String businessId) async {
  try {
    await supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('business_id', businessId);
  } catch (e) {
    rethrow;
  }
}

Future<List<String>> getFavoriteIds(String userId) async {
  try {
    final rows = await supabase
        .from('favorites')
        .select('business_id')
        .eq('user_id', userId);
    return rows.map<String>((e) => e['business_id'] as String).toList();
  } catch (e) {
    rethrow;
  }
}

Future<List<BusinessModel>> getFavoriteBusinesses(String userId) async {
  try {
    final rows = await supabase
        .from('favorites')
        .select('businesses(*)')
        .eq('user_id', userId);
    return rows
        .where((e) => e['businesses'] != null)
        .map<BusinessModel>((e) => BusinessModel.fromSupabase(e['businesses']))
        .toList();
  } catch (e) {
    rethrow;
  }
}
}