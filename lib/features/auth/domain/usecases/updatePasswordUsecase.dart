import 'package:aklatna/features/auth/domain/repositories/auth_repository.dart';

class UpdatePasswordUsecase {
  final AuthRepository repository;
  UpdatePasswordUsecase({required this.repository});

  Future<void> call(String newPassword) {
    return repository.updatePassword(newPassword);
  }
}