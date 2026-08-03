import 'package:aklatna/features/auth/domain/repositories/auth_repository.dart';

class ResendSignUpOtpUsecase {
  final AuthRepository repository;
  ResendSignUpOtpUsecase({required this.repository});

  Future<void> call(String email) {
    return repository.resendSignUpOtp(email);
  }
}