import 'package:aklatna/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aklatna/features/auth/domain/entities/appuser_entity.dart';

class SignUpUsecase {
  final AuthRepositoryImpl repository;
  SignUpUsecase({required this.repository});
  Future<AppuserEntity> call(
    String? email,
    String password,
    String phone,
    String username,
  ) async {
    return await repository.signUp(email, password, username, phone);
  }
}
