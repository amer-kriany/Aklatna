class Profilemodel {
  final String id;
  final String userName;
  final String phoneNumber;
  final bool isPhoneVerified;
  final String email;
  final String? profilePhoto;
  final String address;
  Profilemodel({
    required this.id,
    required this.userName,
    required this.phoneNumber,
    required this.isPhoneVerified,
    required this.email,
    this.profilePhoto, required this.address,
  });
  factory Profilemodel.fromSupabase(Map<String, dynamic> profile) {
    return Profilemodel(
      id: profile['id'],
      userName: profile['username'] ?? "غير محدد",
      phoneNumber: profile['phone_number'] ?? "0000000000",
      isPhoneVerified: profile['is_phone_verified'] ?? "false",
      email: profile['email'] ?? "not_defined@gmail.com",
      profilePhoto: profile['photo'],
      address: profile['address']
    );
  }
}
