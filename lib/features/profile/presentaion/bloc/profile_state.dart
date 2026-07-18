part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final Profileentity profile;
  const ProfileLoaded({required this.profile});
  @override
  List<Object> get props => [profile];
}

final class ProfileUpdated extends ProfileState {}

final class ProfileError extends ProfileState {
  final String message;
  const ProfileError({required this.message});
  @override
  List<Object> get props => [message];
}
