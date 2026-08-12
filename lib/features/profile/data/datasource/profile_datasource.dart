import 'package:aklatna/features/profile/data/model/profileModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDatasource {
  final supabase = Supabase.instance.client;

  // get profile data
 Future<List<Profilemodel>> getProfiles() async {
  try {
    final userId = supabase.auth.currentUser!.id;
    final profiles = await supabase
        .from("profiles")
        .select()
        .eq('id', userId);
    return profiles.map((e) => Profilemodel.fromSupabase(e)).toList();
  } catch (e) {
    rethrow;
  }
}

  // update profile data
 // update profile data
  Future<void> updateProfileData(
    String userId,
    String? username,
    String? bio,
    String? phone,
  ) async {
    try {
      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (bio != null) updates['bio'] = bio;
      if (phone != null) updates['phone_number'] = phone;

      if (updates.isNotEmpty) {
        await supabase
            .from('profiles')
            .update(updates)
            .eq('id', userId);
      }
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
