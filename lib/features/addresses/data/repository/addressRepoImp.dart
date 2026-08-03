import 'package:aklatna/features/addresses/data/dataSource/addressDataSource.dart';
import 'package:aklatna/features/addresses/domain/entity/addressEntity.dart';
import 'package:aklatna/features/addresses/domain/repository/addressRepo.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressDatasource datasource;

  AddressRepositoryImpl({
    required this.datasource,
  });

  @override
  Future<List<AddressEntity>> getAddresses(String userId) async {
    final models = await datasource.getAddresses(userId);

    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addAddress({
    required String userId,
    String? label,
    required String street,
    required String city,
    required String apartment,
    bool isDefault = false,
    double? latitude,
    double? longitude,
  }) {
    return datasource.addAddress(
      userId: userId,
      label: label,
      street: street,
      city: city,
      apartment: apartment,
      isDefault: isDefault,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<void> deleteAddress(String addressId) {
    return datasource.deleteAddress(addressId);
  }

  @override
  Future<void> setDefault({
    required String userId,
    required String addressId,
  }) {
    return datasource.setDefault(
      userId: userId,
      addressId: addressId,
    );
  }
}