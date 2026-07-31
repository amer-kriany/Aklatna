import 'package:aklatna/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aklatna/features/auth/domain/entities/appuser_entity.dart';
import 'package:aklatna/features/auth/domain/repositories/auth_repository.dart';

class Verifysignupotpusecase {
  final AuthRepository repo;
  Verifysignupotpusecase({required this.repo});
  Future<AppuserEntity> call(String email, String token) async {
    return repo.verifySignUpOtp(email, token);
  }
}
