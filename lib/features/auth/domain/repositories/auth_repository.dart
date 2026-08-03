import 'package:aklatna/features/auth/domain/entities/appuser_entity.dart';

abstract class AuthRepository {
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String phone,
  });

  Future<AppuserEntity> signIn(String? email, String? phone, String password);
  Future<AppuserEntity> getCurrentUser();
  Future<void> signOut();

  // NEW
  Future<AppuserEntity> verifySignUpOtp(String email, String token);
  Future<void> resendSignUpOtp(String email);
  Future<void> requestPasswordReset(String email);
  Future<AppuserEntity?> verifyRecoveryOtp(String email, String token);
  Future<void> updatePassword(String newPassword);
}