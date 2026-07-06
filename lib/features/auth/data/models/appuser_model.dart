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
    String asStringOrEmpty(dynamic value) => value?.toString() ?? '';
    String? asNullableString(dynamic value) => value?.toString();

    bool asBoolOrFalse(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      final normalized = value?.toString().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
      return false;
    }

    return AppuserModel(
      id: user.id,
      userName: asStringOrEmpty(profileData['username']),
      email: asNullableString(user.email),
      phone: asNullableString(profileData['phone_number']),
      isPhoneverified: asBoolOrFalse(profileData['is_phone_verified']),
    );
  }
}
