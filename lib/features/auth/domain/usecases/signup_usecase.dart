import 'package:aklatna/features/auth/domain/repositories/auth_repository.dart';

class SignUpUsecase {
  final AuthRepository repository;
  SignUpUsecase({required this.repository});

  Future<bool> call(String email, String password, String username, String phone) {
    return repository.signUp(email: email, password: password, username: username, phone: phone);
  }
}