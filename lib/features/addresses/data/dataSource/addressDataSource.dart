import 'package:aklatna/features/addresses/data/model/addressModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressDatasource {
  final supabase = Supabase.instance.client;

  Future<List<AddressModel>> getAddresses(String userId) async {
    try {
      final response = await supabase
          .from('customer_addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false);

      return response.map((e) => AddressModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAddress({
    required String userId,
    String? label,
    required String street,
    required String city,
    required String apartment,
    bool isDefault = false,
    double? latitude,
    double? longitude,
  }) async {
    try {
      if (isDefault) {
        await supabase
            .from('customer_addresses')
            .update({'is_default': false})
            .eq('user_id', userId);
      }

      await supabase.from('customer_addresses').insert({
        'user_id': userId,
        'label': label,
        'street': street,
        'city': city,
        'apartment': apartment,
        'is_default': isDefault,

        // New location data
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await supabase
          .from('customer_addresses')
          .delete()
          .eq('id', addressId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setDefault({
    required String userId,
    required String addressId,
  }) async {
    try {
      await supabase
          .from('customer_addresses')
          .update({'is_default': false})
          .eq('user_id', userId);

      await supabase
          .from('customer_addresses')
          .update({'is_default': true})
          .eq('id', addressId);
    } catch (e) {
      rethrow;
    }
  }
}