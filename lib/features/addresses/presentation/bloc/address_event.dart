part of 'address_bloc.dart';

sealed class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class LoadAddressesEvent extends AddressEvent {
  final String userId;

  const LoadAddressesEvent({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}

class AddAddressEvent extends AddressEvent {
  final String userId;
  final String? label;
  final String street;
  final String city;
  final String apartment;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  const AddAddressEvent({
    required this.userId,
    this.label,
    required this.street,
    required this.city,
    required this.apartment,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        userId,
        label,
        street,
        city,
        apartment,
        isDefault,
        latitude,
        longitude,
      ];
}

class DeleteAddressEvent extends AddressEvent {
  final String userId;
  final String addressId;

  const DeleteAddressEvent({
    required this.userId,
    required this.addressId,
  });

  @override
  List<Object?> get props => [userId, addressId];
}

class SetDefaultAddressEvent extends AddressEvent {
  final String userId;
  final String addressId;

  const SetDefaultAddressEvent({
    required this.userId,
    required this.addressId,
  });

  @override
  List<Object?> get props => [userId, addressId];
}
class UpdateAddressEvent extends AddressEvent {
  final String userId;
  final String addressId;
  final String? label;
  final String street;
  final String city;
  final String apartment;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  const UpdateAddressEvent({
    required this.userId,
    required this.addressId,
    this.label,
    required this.street,
    required this.city,
    required this.apartment,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        userId,
        addressId,
        label,
        street,
        city,
        apartment,
        isDefault,
        latitude,
        longitude,
      ];
}