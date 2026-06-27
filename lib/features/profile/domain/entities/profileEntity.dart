class Profileentity {
  final String id;
  final String userName;
  final String phoneNumber;
  final bool isPhoneVerified;
  final String email;
  final String? profilePhoto;
  Profileentity({
    required this.id,
    required this.userName,
    required this.phoneNumber,
    required this.isPhoneVerified,
    required this.email,
    this.profilePhoto,
  });
}
