import 'package:aklatna/features/profile/domain/entities/profileEntity.dart';
import 'package:aklatna/features/profile/domain/usecases/getProfilesUsecase.dart';
import 'package:aklatna/features/profile/domain/usecases/updateProfilePhotoUseCase.dart';
import 'package:aklatna/features/profile/domain/usecases/updateProfileUsecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final Getprofilesusecase getProfilesUsecase;
  final Updateprofileusecase updateProfileUsecase;
  final Updateprofilephotousecase updateprofilephotousecase;
  ProfileBloc({
    required this.getProfilesUsecase,
    required this.updateProfileUsecase,
    required this.updateprofilephotousecase,
  }) : super(ProfileInitial()) {
    on<GetProfilesEvent>(_getProfiles);
    on<UpdateProfileEvent>(_updateProfileData);
    on<UpdateProfilePhotoEvent>(_updateProfilePhoto);
  }
  // get profile data
  Future<void> _getProfiles(
    GetProfilesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      print("profile staring");
      final profiles = await getProfilesUsecase();
      if (profiles.isNotEmpty) {
        emit(ProfileLoaded(profile: profiles.first));
      }
      print("profile loaded");
    } catch (e) {
      emit(ProfileError(message: e.toString()));
      print("profile failed");
    }
  }

  // update profile data
  Future<void> _updateProfileData(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      await updateProfileUsecase(event.userId, event.username, event.address,event.bio);
      emit(ProfileUpdated());
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

 // update profile Photo
  Future<void> _updateProfilePhoto(
    UpdateProfilePhotoEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      // 1. Run the update usecase
      await updateprofilephotousecase(event.userId, event.photo);
      
      // 2. Immediately re-fetch profiles so state becomes ProfileLoaded with new photo!
      final profiles = await getProfilesUsecase();
      if (profiles.isNotEmpty) {
        emit(ProfileLoaded(profile: profiles.first));
      } else {
        emit(ProfileUpdated());
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
