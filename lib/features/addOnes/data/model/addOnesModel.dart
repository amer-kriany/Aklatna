import 'package:aklatna/features/addOnes/domain/enitity/addOnesEntity.dart';

class AddonModel {
  final String id;
  final String name;
  final double price;
  final String itemId;

  AddonModel({required this.id, required this.name, required this.price, required this.itemId});

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    return AddonModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      itemId: json['item_id']?.toString() ?? '',
    );
  }

  AddonEntity toEntity() => AddonEntity(id: id, name: name, price: price, itemId: itemId);
}