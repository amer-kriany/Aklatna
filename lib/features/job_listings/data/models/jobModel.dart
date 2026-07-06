class Jobmodel {
  final String title;
  final String description;
  final String location;
  final String businessId;
  final String requirements;
  final String contactPhone;
  final String isApproved;
  final String isActive;
  final String businessName;

  Jobmodel({
    required this.title,
    required this.description,
    required this.location,
    required this.businessId,
    required this.requirements,
    required this.contactPhone,
    required this.isApproved,
    required this.isActive,
    required this.businessName,
  });

  factory Jobmodel.fromJson(Map<String, dynamic> json) {
    String asStringOrEmpty(dynamic value) => value?.toString() ?? '';

    return Jobmodel(
      title: asStringOrEmpty(json['title']),
      description: asStringOrEmpty(json['description']),
      location: asStringOrEmpty(json['location']),
      businessId: asStringOrEmpty(json['businessId']),
      requirements: asStringOrEmpty(json['requirements']),
      contactPhone: asStringOrEmpty(json['contactPhone']),
      isApproved: asStringOrEmpty(json['isApproved']),
      isActive: asStringOrEmpty(json['isActive']),
      businessName: asStringOrEmpty(json['businessName']),
    );
  }
}
