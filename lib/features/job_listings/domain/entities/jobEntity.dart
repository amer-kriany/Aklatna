class JobEntity {
  final String title;
  final String description;
  final String location;
  final String businessId;
  final String requirements;
  final String contactPhone;
  final String isApproved;
  final String isActive;
  final String businessName;

  JobEntity({
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
}
