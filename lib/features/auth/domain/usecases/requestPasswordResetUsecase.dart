import 'package:aklatna/features/auth/domain/repositories/auth_repository.dart';

class Requestpasswordresetusecase {
  final AuthRepository repo;
  Requestpasswordresetusecase({required this.repo});
  Future<void> call(String email) async {
    return repo.requestPasswordReset(email);
  }
}
