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
    return Jobmodel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      businessId: json['businessId'] ?? '',
      requirements: json['requirements'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      isApproved: json['isApproved'] ?? '',
      isActive: json['isActive'] ?? '',
      businessName: json['businessName'] ?? '',
    );
  }
}
