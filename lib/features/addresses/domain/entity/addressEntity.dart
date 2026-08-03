class AddressEntity {
  final String id;
  final String userId;
  final String? label;
  final String street;
  final String city;
  final String apartment;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  AddressEntity({
    required this.id,
    required this.userId,
    this.label,
    required this.street,
    required this.city,
    required this.apartment,
    required this.isDefault,
    this.latitude,
    this.longitude,
  });
}