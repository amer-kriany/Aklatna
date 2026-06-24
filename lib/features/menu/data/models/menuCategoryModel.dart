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
    return Menucategorymodel(
      id: menuCategory['id'],
      businessId: menuCategory['business_id'],
      nameAr: menuCategory['name_ar'],
      sortOrder: menuCategory['sort_order'],
    );

    
  }
}
