part of 'add_ones_bloc.dart';

sealed class AddOnesState extends Equatable {
  const AddOnesState();
  
  @override
  List<Object> get props => [];
}

final class AddOnesInitial extends AddOnesState {}
final class AddonLoading extends AddOnesState {}

final class AddonLoaded extends AddOnesState {
  final List<AddonEntity> addons;
  const AddonLoaded({required this.addons});
  @override
  List<Object> get props => [addons];
}

final class AddonError extends AddOnesState {
  final String message;
  const AddonError({required this.message});
  @override
  List<Object> get props => [message];
}
