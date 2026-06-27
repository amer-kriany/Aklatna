import 'package:aklatna/features/profile/data/repository/profileRepoImp.dart';
import 'package:aklatna/features/profile/domain/entities/profileEntity.dart';

class Getprofilesusecase {
  final Profilerepoimp repo;
  Getprofilesusecase({required this.repo});

  Future<List<Profileentity>> call() async {
    return await repo.getProfiles() ;
  }
}
