import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_state.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'cart_event.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState.initial()) {
    on<AddItemEvent>(_onAddItem);
    on<RemoveItemEvent>(_onRemoveItem);
    on<ClearCartEvent>(_onClearCart);
  }

 void _onAddItem(AddItemEvent event, Emitter<CartState> emit) {
  // Different restaurant → clear cart first
  if (state.businessId != null && state.businessId != event.item.businessId) {
    emit(CartState.initial());
  }

  final existingIndex = state.items.indexWhere(
    (i) => i.itemId == event.item.itemId,
  );

  List<CartItem> updatedItems = List.from(state.items);

  if (existingIndex != -1) {
    final existing = updatedItems[existingIndex];
    updatedItems[existingIndex] = existing.copyWith(
      quantity: existing.quantity + 1,
    );
  } else {
    updatedItems.add(event.item);
  }

  emit(state.copyWith(
    items: updatedItems,
    businessId: event.item.businessId,
    businessName: event.businessName ?? state.businessName,
    businessLogo: event.businessLogo ?? state.businessLogo,
    totalPrice: _calcTotal(updatedItems),
  ));
}

  void _onRemoveItem(RemoveItemEvent event, Emitter<CartState> emit) {
    List<CartItem> updatedItems = List.from(state.items);
    final index = updatedItems.indexWhere((i) => i.itemId == event.itemId);
    if (index == -1) return;

    if (updatedItems[index].quantity > 1) {
      updatedItems[index] = updatedItems[index].copyWith(
        quantity: updatedItems[index].quantity - 1,
      );
    } else {
      updatedItems.removeAt(index);
    }

   emit(state.copyWith(
  items: updatedItems,
  totalPrice: _calcTotal(updatedItems),
  clearBusinessId: updatedItems.isEmpty,
));
  }

  void _onClearCart(ClearCartEvent event, Emitter<CartState> emit) {
    emit(CartState.initial());
  }

  double _calcTotal(List<CartItem> items) {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}