class Promotionmodel {
  final String id;
  final String label;
  final int discountPercentage;
  final String businessId;
  final String? imageUrl;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  const Promotionmodel({
    required this.id,
    required this.label,
    required this.discountPercentage,
    required this.businessId,
    required this.startTime,
    required this.endTime,
    this.imageUrl, required this.createdAt,
  });

  factory Promotionmodel.fromJson(Map<String, dynamic> json) {
    return Promotionmodel(
      id: json['id'],
      label: json['label'],
      discountPercentage: json['discountPercentage'],
      businessId: json['businessId'],
      imageUrl: json['imageUrl'],
      startTime: DateTime.parse(json['start_time']),
      endTime:DateTime.parse(json['end_time']) ,
      createdAt: DateTime.parse(json['created_at'])
    );
  }
}
