part of 'cart_bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddItemEvent extends CartEvent {
  final CartItem item;
  const AddItemEvent({required this.item});
}

class RemoveItemEvent extends CartEvent {
  final String itemId;
  const RemoveItemEvent({required this.itemId});
}

class ClearCartEvent extends CartEvent {}

