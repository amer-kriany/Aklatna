part of 'menu_bloc.dart';

sealed class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

final class GetMenu extends MenuEvent {
  final String id;
  const GetMenu({required this.id});

  @override
  List<Object> get props => [id];
}

// NEW — fetches everything, for list-based screens like Search's popular carousel
final class GetAllMenu extends MenuEvent {
  const GetAllMenu();
}