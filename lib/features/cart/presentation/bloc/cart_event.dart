part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddItemEvent extends CartEvent {
  final CartItem item;
  final String? businessName;
  final String? businessLogo;

  const AddItemEvent({
    required this.item,
    this.businessName,
    this.businessLogo,
  });

  @override
  List<Object?> get props => [item, businessName, businessLogo];
}

class RemoveItemEvent extends CartEvent {
  final String itemId;
  const RemoveItemEvent({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}