import 'package:aklatna/features/addresses/domain/entity/addressEntity.dart';

abstract class AddressRepository {
  Future<List<AddressEntity>> getAddresses(String userId);
  Future<void> addAddress({required String userId, String? label, required String street, required String city, required String apartment, bool isDefault = false});
  Future<void> deleteAddress(String addressId);
  Future<void> setDefault({required String userId, required String addressId});
}