import 'package:aklatna/features/profile/domain/entities/profileEntity.dart';
import 'package:aklatna/features/profile/domain/usecases/getProfilesUsecase.dart';
import 'package:aklatna/features/profile/domain/usecases/updateProfileUsecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final Getprofilesusecase getProfilesUsecase;
  final Updateprofileusecase updateProfileUsecase;
  ProfileBloc({
    required this.getProfilesUsecase,
    required this.updateProfileUsecase,
  }) : super(ProfileInitial()) {
    on<GetProfilesEvent>(_getProfiles);
    on<UpdateProfileEvent>(_updateProfileData);
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
      emit(ProfileLoaded(profiles: profiles));
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
      await updateProfileUsecase(
        event.userId,
        event.username,
        event.address,
        event.photo,
      );
      emit(ProfileUpdated());
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
