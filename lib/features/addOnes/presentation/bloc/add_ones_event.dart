part of 'add_ones_bloc.dart';

sealed class AddOnesEvent extends Equatable {
  const AddOnesEvent();

  @override
  List<Object> get props => [];
}
class GetAddonsEvent extends AddOnesEvent {
  final String itemId;
  const GetAddonsEvent({required this.itemId});
  @override
  List<Object> get props => [itemId];
}
