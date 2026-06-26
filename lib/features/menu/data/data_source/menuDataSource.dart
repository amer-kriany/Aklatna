import 'package:aklatna/features/menu/data/models/menuCategoryModel.dart';
import 'package:aklatna/features/menu/data/models/menuItemModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Menudatasource {
  final supabase = Supabase.instance.client;

  // get category_menu
  Future<List<Menucategorymodel>> getMenuCategories() async {
    try {
      final response = await supabase.from("menu_categories").select();
      if (response.isEmpty) {
        throw "empty result";
      }
      return response.map((e)=>Menucategorymodel.fromSupabase(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
  // get menu_items
  Future<List<Menuitemmodel>> getMenuItems() async {
    try {
      final response = await supabase.from("menu_items").select();
      if (response.isEmpty) {
        throw "empty result";
      }
      return response.map((e)=>Menuitemmodel.fromSupabase(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
