import 'package:supabase_flutter/supabase_flutter.dart';

class AppuserModel {
  final String id;
  final String userName;
  final String? email;
  final String? phone;
  final bool isPhoneverified;
  AppuserModel({
    required this.id,
    required this.userName,
     this.email,
    required this.phone,
    required this.isPhoneverified,
  });

  factory AppuserModel.fromSupabase(
    User user,
    Map<String, dynamic> profileData,
  ) {
    return AppuserModel(id: user.id,
     userName: profileData['username'],
      email: user.email,
       phone: profileData['phone_number'],
       isPhoneverified: profileData['is_phone_verified'] ?? false,
       ); 
  }
}
