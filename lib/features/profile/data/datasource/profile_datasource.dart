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
    String? photo,
  ) async {
    try {
      await supabase
          .from('profiles')
          .update({'username': username, 'adress': address, 'photo': photo})
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }
}
