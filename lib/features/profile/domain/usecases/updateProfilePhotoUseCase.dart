import 'package:aklatna/features/profile/domain/repository/profileRepo.dart';

class Updateprofilephotousecase {
  final Profilerepo repo;
  Updateprofilephotousecase({required this.repo});

  Future<void> call(String userId, String? photo) async {
    return await repo.updateProfilePhoto(userId, photo);
  }
}
