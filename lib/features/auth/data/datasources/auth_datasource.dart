import 'package:aklatna/features/auth/data/models/appuser_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDatasource {
  final supabase = Supabase.instance.client;

  // sign up
  Future<bool> signUp({
  required String email,
  required String password,
  required String username,
  required String phone,
}) async {
  try {
    final response = await supabase.auth.signUp(
      password: password,
      email: email,
      data: {
        'username': username,
        'phone_number': phone,
        'role': "user",
      },
    );
    return response.user != null;
  } catch (e) {
    rethrow;
  }
}
Future<void> requestPasswordReset(String email) async {
  try {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'https://amer-kriany.github.io/aklatna_confirm/reset-password.html',
    );
  } catch (e) {
    rethrow;
  }
}

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
        params: {'input_phone': phone},
      );

      if (foundEmail == null) {
        throw Exception('رقم الهاتف غير مسجل');
      }
      authEmail = foundEmail as String;
    }

    final response = await supabase.auth.signInWithPassword(
      email: authEmail,
      password: password,
    );

    final user = response.user;
    if (user != null) {
      final profileData = await supabase
          .from("profiles")
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profileData == null) {
        throw Exception('تعذر العثور على الملف الشخصي');
      }

      return AppuserModel.fromSupabase(user, profileData);
    }
    return null;
  } catch (e) {
    rethrow;
  }
}
 

  // log out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // get current user
  Future<AppuserModel?> getCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final profileData = await supabase
            .from("profiles")
            .select()
            .eq('id', user.id)
            .single();
        return AppuserModel.fromSupabase(user, profileData);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  Future<void> resendSignUpOtp(String email) async {
  try {
    await supabase.auth.resend(type: OtpType.signup, email: email);
  } catch (e) {
    rethrow;
  }
}
Future<AppuserModel?> verifySignUpOtp(String email, String token) async {
  try {
    final response = await supabase.auth.verifyOTP(
      type: OtpType.signup,
      email: email,
      token: token,
    );

    final user = response.user;
    if (user != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      final profileData = await supabase
          .from("profiles")
          .select()
          .eq('id', user.id)
          .single();
      return AppuserModel.fromSupabase(user, profileData);
    }
    return null;
  } catch (e) {
    rethrow;
  }
}

Future<AppuserModel?> verifyRecoveryOtp(String email, String token) async {
  try {
    final response = await supabase.auth.verifyOTP(
      type: OtpType.recovery,
      email: email,
      token: token,
    );

    final user = response.user;
    if (user != null) {
      final profileData = await supabase
          .from("profiles")
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (profileData != null) {
        return AppuserModel.fromSupabase(user, profileData);
      }
    }
    return null;
  } catch (e) {
    rethrow;
  }
}

Future<void> updatePassword(String newPassword) async {
  try {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  } catch (e) {
    rethrow;
  }
}
}
