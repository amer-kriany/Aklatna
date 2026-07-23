import 'package:aklatna/features/addresses/domain/entity/addressEntity.dart';
import 'package:aklatna/features/addresses/domain/repository/addressRepo.dart';

class GetAddressesUsecase {
  final AddressRepository repo;
  GetAddressesUsecase({required this.repo});
  Future<List<AddressEntity>> call(String userId) => repo.getAddresses(userId);
}

class AddAddressUsecase {
  final AddressRepository repo;
  AddAddressUsecase({required this.repo});
  Future<void> call({required String userId, String? label, required String street, required String city, required String apartment, bool isDefault = false}) =>
      repo.addAddress(userId: userId, label: label, street: street, city: city, apartment: apartment, isDefault: isDefault);
}

class DeleteAddressUsecase {
  final AddressRepository repo;
  DeleteAddressUsecase({required this.repo});
  Future<void> call(String addressId) => repo.deleteAddress(addressId);
}

class SetDefaultAddressUsecase {
  final AddressRepository repo;
  SetDefaultAddressUsecase({required this.repo});
  Future<void> call({required String userId, required String addressId}) =>
      repo.setDefault(userId: userId, addressId: addressId);
}