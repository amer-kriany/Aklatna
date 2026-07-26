class AddressEntity {
  final String id;
  final String userId;
  final String? label;
  final String street;
  final String city;
  final String apartment;
  final bool isDefault;

  AddressEntity({
    required this.id,
    required this.userId,
    this.label,
    required this.street,
    required this.city,
    required this.apartment,
    required this.isDefault,
  });
}