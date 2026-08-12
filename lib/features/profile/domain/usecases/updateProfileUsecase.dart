import 'package:aklatna/features/profile/domain/repository/profileRepo.dart';

class Updateprofileusecase {
  final Profilerepo repo;
  Updateprofileusecase({required this.repo});

  Future<void> call( String userId,
    String? username,
    String? bio,
    String? phone,
    ) async {
    return  await repo.updateProfileData(userId, username,bio,phone); 
  }
}
