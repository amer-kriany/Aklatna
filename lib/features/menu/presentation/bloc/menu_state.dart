part of 'menu_bloc.dart';

sealed class MenuState extends Equatable {
  const MenuState();
  
  @override
  List<Object> get props => [];
}

final class MenuInitial extends MenuState {}
final class MenuLoading extends MenuState {}

final class MenuLoaded extends MenuState {
  final List<Menucategoryentity> categories;
  final List<Menuitementity> items;
  const MenuLoaded({required this.categories, required this.items});

}
final class MenuError extends MenuState {
  final String message;
  const MenuError({required this.message});
}
