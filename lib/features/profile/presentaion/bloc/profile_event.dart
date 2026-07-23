part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class GetProfilesEvent extends ProfileEvent {}
class UpdateProfileEvent extends ProfileEvent {
  final String userId;
  final String? username;
  final String? address;
  final String? bio;

  const UpdateProfileEvent({
    required this.userId,
    this.username,
    this.address, this.bio,
  });

  @override
  List<Object> get props => [userId, username ?? '', address ?? '',bio??'' ];
}
class UpdateProfilePhotoEvent extends ProfileEvent {
  final String userId;
  final String photo;

  const UpdateProfilePhotoEvent({
    required this.userId,
    required this.photo,
  });

  @override
  List<Object> get props => [userId, photo];
}