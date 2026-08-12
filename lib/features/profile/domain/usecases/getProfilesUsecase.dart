import 'package:aklatna/features/profile/domain/entities/profileEntity.dart';
import 'package:aklatna/features/profile/domain/repository/profileRepo.dart';

class Getprofilesusecase {
  final Profilerepo repo;
  Getprofilesusecase({required this.repo});

  Future<List<Profileentity>> call() async {
    return await repo.getProfiles() ;
  }
}
