class Menucategoryentity {
  final String id;
  final String businessId;
  final String? name;
  final String nameAr;
  final int sortOrder;
  Menucategoryentity({
    required this.id,
    required this.businessId,
    this.name,
    required this.nameAr,
    required this.sortOrder,
  });
}
