import 'package:aklatna/features/auth/domain/entities/appuser_entity.dart';

abstract class AuthRepository {
  Future<AppuserEntity> signUp(
    String? email,
    String password,
    String username,
    String phone,
  );
  Future<AppuserEntity> signIn(String? email, String? phone, String password);
  Future<AppuserEntity> getCurrentUser();
  Future<void> signOut();

   
}
