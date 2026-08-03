import 'package:aklatna/features/profile/data/repository/profileRepoImp.dart';

class Updateprofileusecase {
  final Profilerepoimp repo;
  Updateprofileusecase({required this.repo});

  Future<void> call( String userId,
    String? username,
    String? bio,
    String? phone,
    ) async {
    return  await repo.updateProfileData(userId, username,bio,phone); 
  }
}
