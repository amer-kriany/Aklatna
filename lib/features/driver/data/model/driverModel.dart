class DriverModel {
  final String id;
  final String name;
  final String phone;
  final bool isActive;

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.isActive,
  });

  factory DriverModel.fromSupabase(Map<String, dynamic> row) {
    return DriverModel(
      id: row['id']?.toString() ?? '',
      name: row['name']?.toString() ?? '',
      phone: row['phone']?.toString() ?? '',
      isActive: row['is_active'] == true,
    );
  }
}