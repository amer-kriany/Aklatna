import 'package:aklatna/features/profile/data/model/profileModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDatasource {
  final supabase = Supabase.instance.client;

  // get profile data
  Future<List<Profilemodel>> getProfiles() async {
    try {
      final profiles = await supabase.from("profiles").select();
      print(profiles);
      print(profiles.runtimeType);
      print(Supabase.instance.client.auth.currentUser?.id);
      return profiles.map((e) => Profilemodel.fromSupabase(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // update profile data
  Future<void> updateProfileData(
    String userId,
    String? username,
    String? address,
  ) async {
    try {
      await supabase
          .from('profiles')
          .update({'username': username, 'address': address})
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // update profile photo
  Future<void> updateProfilePhoto(String? photo,String userId) async {
    try {
      await supabase.from('profiles').update({'photo': photo}).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }
}
