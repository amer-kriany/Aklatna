class Profilemodel {
  final String id;
  final String userName;
  final String phoneNumber;
  final bool isPhoneVerified;
  final String email;
  final String? photo;
  final String address;
  Profilemodel({
    required this.id,
    required this.userName,
    required this.phoneNumber,
    required this.isPhoneVerified,
    required this.email,
    this.photo,
    required this.address,
  });
  factory Profilemodel.fromSupabase(Map<String, dynamic> profile) {
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

    return Profilemodel(
      id: asStringOrEmpty(profile['id']),
      userName: asStringOrEmpty(profile['username']),
      phoneNumber: asStringOrEmpty(profile['phone_number']),
      isPhoneVerified: asBoolOrFalse(profile['is_phone_verified']),
      email: asStringOrEmpty(profile['email']),
      photo: asNullableString(profile['photo']),
      address: asStringOrEmpty(profile['address']),
    );
    
  }
}
