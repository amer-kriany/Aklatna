import 'package:aklatna/features/addresses/domain/entity/addressEntity.dart';

class AddressModel {
  final String id;
  final String userId;
  final String? label;
  final String street;
  final String city;
  final String apartment;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.userId,
    this.label,
    required this.street,
    required this.city,
    required this.apartment,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'].toString(),
      userId: json['user_id']?.toString() ?? '',
      label: json['label']?.toString(),
      street: json['street']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      apartment: json['apartment']?.toString() ?? '',
      isDefault: json['is_default'] == true,
    );
  }

  AddressEntity toEntity() => AddressEntity(
    id: id,
    userId: userId,
    label: label,
    street: street,
    city: city,
    apartment: apartment,
    isDefault: isDefault,
  );
}