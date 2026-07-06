class Menucategorymodel {
  final String id;
  final String businessId;
  final String? name;
  final String nameAr;
  final int sortOrder;
  Menucategorymodel({
    required this.id,
    required this.businessId,
    this.name,
    required this.nameAr,
    required this.sortOrder,
  });
  factory Menucategorymodel.fromSupabase(Map<String, dynamic> menuCategory) {
    String asStringOrEmpty(dynamic value) => value?.toString() ?? '';

    int asIntOrZero(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return Menucategorymodel(
      id: asStringOrEmpty(menuCategory['id']),
      businessId: asStringOrEmpty(menuCategory['business_id']),
      nameAr: asStringOrEmpty(menuCategory['name_ar']),
      sortOrder: asIntOrZero(menuCategory['sort_order']),
    );
  }
}
