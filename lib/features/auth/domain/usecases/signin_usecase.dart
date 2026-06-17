import 'package:aklatna/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aklatna/features/auth/domain/entities/appuser_entity.dart';

class SigninUsecase {
  final AuthRepositoryImpl repository;
  SigninUsecase({required this.repository});
  Future<AppuserEntity> call(String? email, String password , String? phone) async {
    return await repository.signIn(email , phone , password);
  }
}