class Profileentity {
  final String id;
  final String userName;
  final String phoneNumber;
  final bool isPhoneVerified;
  final String email;
  final String? photo;
  final String? bio;
  final String address;

  Profileentity({
    required this.id,
    required this.userName,
    required this.phoneNumber,
    required this.isPhoneVerified,
    required this.email,
    this.photo,
    required this.address,
    this.bio,
  });
}