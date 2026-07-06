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
    this.imageUrl,
    required this.createdAt,
  });

  factory Promotionmodel.fromJson(Map<String, dynamic> json) {
    String asStringOrEmpty(dynamic value) => value?.toString() ?? '';
    String? asNullableString(dynamic value) => value?.toString();

    int asIntOrZero(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    DateTime asDateOrEpoch(dynamic value) {
      if (value is DateTime) return value;
      return DateTime.tryParse(value?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Promotionmodel(
      id: asStringOrEmpty(json['id']),
      label: asStringOrEmpty(json['label']),
      discountPercentage: asIntOrZero(json['discountPercentage']),
      businessId: asStringOrEmpty(json['businessId']),
      imageUrl: asNullableString(json['imageUrl']),
      startTime: asDateOrEpoch(json['start_time']),
      endTime: asDateOrEpoch(json['end_time']),
      createdAt: asDateOrEpoch(json['created_at']),
    );
  }
}
