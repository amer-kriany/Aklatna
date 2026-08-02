import 'package:aklatna/features/auth/domain/entities/appuser_entity.dart';
import 'package:aklatna/features/auth/domain/repositories/auth_repository.dart';

class SigninUsecase {
  final AuthRepository repository;
  SigninUsecase({required this.repository});
  Future<AppuserEntity> call(String? email, String password , String? phone) async {
    return await repository.signIn(email , phone , password);
  }
}