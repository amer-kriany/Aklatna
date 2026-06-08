import 'package:supabase_flutter/supabase_flutter.dart';

class AppuserModel {
  final String id;
  final String userName;
  final String? email;
  final String? phone;
  final bool isPhoneProtected;
  AppuserModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.phone,
    required this.isPhoneProtected,
  });

  factory AppuserModel.fromSupabase(
    User user,
    Map<String, dynamic> profileData,
  ) {
    return AppuserModel(id: user.id,
     userName: profileData['username'],
      email: user.email,
       phone: user.phone,
       isPhoneProtected: profileData['is_phone_protected']); 
  }
}
