import 'package:aklatna/features/auth/data/models/appuser_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDatasource {
  final supabase = Supabase.instance.client;

  // sign up
  Future<AppuserModel?> signUp(
    String? email,
    String password,
    String username,
    String phone,
  ) async {
    try {
      final AuthResponse response;
        response = await supabase.auth.signUp(
          password: password,
          email: email,
          phone: phone,
        );
      
      final user = response.user;

      if (user != null) {
        await supabase.from("profiles").insert({
          "id": user.id,
          "username": username,
          "is_phone_verified": false,
        });
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
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
        phone: phone,
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
  Future<AppuserModel?> getCurrentUser(String id) async {
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
