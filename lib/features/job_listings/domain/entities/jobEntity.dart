class JobEntity {
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

  JobEntity({
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
}