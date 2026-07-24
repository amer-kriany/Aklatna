import 'package:aklatna/features/profile/domain/entities/profileEntity.dart';

abstract class Profilerepo {
  // get profile data
  Future<List<Profileentity>> getProfiles();
  // update profile photo
  Future<void> updateProfilePhoto(String userId, String? photo);
  // update profile data
  Future<void> updateProfileData(
    String userId,
    String? username,
    String? bio,
  );
}
