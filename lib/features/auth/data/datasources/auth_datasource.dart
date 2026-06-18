import 'package:aklatna/features/auth/data/models/appuser_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDatasource {
  final supabase = Supabase.instance.client;

  // sign up
  Future<AppuserModel?> signUp({
    required String email,
    required String password,
    required String username,
    required String phone,
  }) async {
    try {
      final AuthResponse response;
      response = await supabase.auth.signUp(password: password, email: email,
      data: {
    'username': username,
    'phone_number': phone,
  },);

      final user = response.user;

      if (user != null) {
       await Future.delayed(const Duration(milliseconds: 500));
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

  // sign in
  Future<AppuserModel?> signIn(
    String? email,
    String? phone,
    String password,
  ) async {
    try {
      String? authEmail = email;
      if (phone != null && email == null) {
        final emailResponse = await supabase
            .from("profiles")
            .select("email")
            .eq("phone_number", phone)
            .single();
        authEmail = emailResponse["email"];
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
            .single();
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
}
