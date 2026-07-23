part of 'address_bloc.dart';

sealed class AddressEvent extends Equatable {
  const AddressEvent();
  @override
  List<Object?> get props => [];
}

class LoadAddressesEvent extends AddressEvent {
  final String userId;
  const LoadAddressesEvent({required this.userId});
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
  const AddAddressEvent({
    required this.userId,
    this.label,
    required this.street,
    required this.city,
    required this.apartment,
    this.isDefault = false,
  });
  @override
  List<Object?> get props => [userId, label, street, city, apartment, isDefault];
}

class DeleteAddressEvent extends AddressEvent {
  final String userId;
  final String addressId;
  const DeleteAddressEvent({required this.userId, required this.addressId});
  @override
  List<Object?> get props => [userId, addressId];
}

class SetDefaultAddressEvent extends AddressEvent {
  final String userId;
  final String addressId;
  const SetDefaultAddressEvent({required this.userId, required this.addressId});
  @override
  List<Object?> get props => [userId, addressId];
}