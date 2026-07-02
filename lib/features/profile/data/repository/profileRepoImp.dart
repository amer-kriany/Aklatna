import 'package:aklatna/features/profile/data/datasource/profile_datasource.dart';
import 'package:aklatna/features/profile/data/model/profileModel.dart';
import 'package:aklatna/features/profile/domain/entities/profileEntity.dart';
import 'package:aklatna/features/profile/domain/repository/profileRepo.dart';

class Profilerepoimp implements Profilerepo {
  final ProfileDatasource profileDatasource;
  Profilerepoimp({required this.profileDatasource});
  @override
  Future<List<Profileentity>> getProfiles() async {
    final profiles = await profileDatasource.getProfiles();
    return profiles.map((e) => mapToEntity(e)).toList();
  }

  @override
  Future<void> updateProfileData(
    String userId,
    String? username,
    String? address,
    String? photo,
  ) async {
    await profileDatasource.updateProfileData(userId, username, address, photo);
  }
}

Profileentity mapToEntity(Profilemodel model) {
  return Profileentity(
    id: model.id,
    userName: model.userName,
    phoneNumber: model.phoneNumber,
    isPhoneVerified: model.isPhoneVerified,
    email: model.email,
  );
  
}
