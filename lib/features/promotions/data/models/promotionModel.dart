class Promotionmodel {
  final String id;
  final String label;
  final int discountPercentage;
  final String businessId;
  final String? imageUrl;
  final String startTime;
  final String endTime;
  const Promotionmodel({
    required this.id,
    required this.label,
    required this.discountPercentage,
    required this.businessId,
    required this.startTime,
    required this.endTime, this.imageUrl,
  });

  factory Promotionmodel.fromJson(Map<String, dynamic> json) {
    return Promotionmodel(
      id: json['id'],
      label: json['label'],
      discountPercentage: json['discountPercentage'],
      businessId: json['businessId'],
      imageUrl: json['imageUrl'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}

