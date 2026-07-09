part of 'menu_bloc.dart';

sealed class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object> get props => [];
}

final class MenuInitial extends MenuState {}

final class MenuLoading extends MenuState {}

final class MenuLoaded extends MenuState {
  final Menucategoryentity category;
  final Menuitementity item;
  const MenuLoaded({required this.category, required this.item});
}

final class MenuAllLoaded extends MenuState {
  final List<Menuitementity> items;
  final List<Menucategoryentity> categories;
  const MenuAllLoaded({required this.items, required this.categories});

  @override
  List<Object> get props => [items, categories];
}

final class MenuError extends MenuState {
  final String message;
  const MenuError({required this.message});
}
