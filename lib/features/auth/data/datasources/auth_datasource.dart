import 'package:aklatna/features/auth/data/models/appuser_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDatasource {
  final supabase = Supabase.instance.client;

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String phone,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'phone_number': phone,
          'role': 'user',
        },
      );

      return response.user != null;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // REQUEST PASSWORD RESET
  // ============================================================

  Future<void> requestPasswordReset(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo:
            'https://amer-kriany.github.io/aklatna_confirm/reset-password.html',
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // SIGN IN
  // ============================================================

  Future<AppuserModel?> signIn(
    String? email,
    String? phone,
    String password,
  ) async {
    try {
      String? authEmail = email;

      if (phone != null && email == null) {
        final foundEmail = await supabase.rpc(
          'get_email_by_phone',
          params: {
            'input_phone': phone,
          },
        );

        if (foundEmail == null) {
          throw Exception('رقم الهاتف غير مسجل');
        }

        authEmail = foundEmail as String;
      }

      final response =
          await supabase.auth.signInWithPassword(
        email: authEmail,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        final profileData = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profileData == null) {
          throw Exception(
            'تعذر العثور على الملف الشخصي',
          );
        }

        return AppuserModel.fromSupabase(
          user,
          profileData,
        );
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  Future<AppuserModel?> getCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;

      if (user != null) {
        final profileData = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        return AppuserModel.fromSupabase(
          user,
          profileData,
        );
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // RESEND SIGN UP OTP
  // ============================================================

  Future<void> resendSignUpOtp(
    String email,
  ) async {
    try {
      await supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // VERIFY SIGN UP OTP
  // ============================================================

  Future<AppuserModel?> verifySignUpOtp(
    String email,
    String token,
  ) async {
    try {
      final response =
          await supabase.auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: token,
      );

      final user = response.user;

      if (user != null) {
        await Future.delayed(
          const Duration(milliseconds: 300),
        );

        final profileData = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        return AppuserModel.fromSupabase(
          user,
          profileData,
        );
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // VERIFY RECOVERY OTP
  //
  // Only needed if you decide to use OTP recovery.
  // Not used by the GitHub reset-password page.
  // ============================================================

  Future<AppuserModel?> verifyRecoveryOtp(
    String email,
    String token,
  ) async {
    try {
      final response =
          await supabase.auth.verifyOTP(
        type: OtpType.recovery,
        email: email,
        token: token,
      );

      final user = response.user;

      if (user != null) {
        final profileData = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profileData != null) {
          return AppuserModel.fromSupabase(
            user,
            profileData,
          );
        }
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // UPDATE PASSWORD
  // ============================================================

  Future<void> updatePassword(
    String newPassword,
  ) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}