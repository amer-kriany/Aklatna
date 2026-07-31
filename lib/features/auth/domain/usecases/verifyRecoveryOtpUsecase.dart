import 'package:aklatna/features/auth/domain/entities/appuser_entity.dart';
import 'package:aklatna/features/auth/domain/repositories/auth_repository.dart';

class VerifyRecoveryOtpUsecase {
  final AuthRepository repository;
  VerifyRecoveryOtpUsecase({required this.repository});

  Future<AppuserEntity?> call(String email, String token) {
    return repository.verifyRecoveryOtp(email, token);
  }
}