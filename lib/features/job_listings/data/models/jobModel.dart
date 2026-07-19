class Jobmodel {
  final String id;
  final String title;
  final String description;
  final String businessId;
  final String businessName;
  final String location;
  final String requirements;
  final String contactPhone;
  final bool isApproved;
  final bool isActive;

  Jobmodel({
    required this.id,
    required this.title,
    required this.description,
    required this.businessId,
    required this.businessName,
    required this.location,
    required this.requirements,
    required this.contactPhone,
    required this.isApproved,
    required this.isActive,
  });

  factory Jobmodel.fromJson(Map<String, dynamic> json) {
  String asStringOrEmpty(dynamic value) => value?.toString() ?? '';
  bool asBoolOrFalse(dynamic value) => value == true;

  return Jobmodel(
    id: asStringOrEmpty(json['id']),
    title: asStringOrEmpty(json['title']),
    description: asStringOrEmpty(json['description']),
    businessId: asStringOrEmpty(json['business_id']),
    businessName: asStringOrEmpty(json['business_name']),
    location: asStringOrEmpty(json['location']),
    requirements: asStringOrEmpty(json['requirements']),
    contactPhone: asStringOrEmpty(json['contact_phone']),
    isApproved: asBoolOrFalse(json['is_approved']),
    isActive: asBoolOrFalse(json['is_active']),
  );
}
}