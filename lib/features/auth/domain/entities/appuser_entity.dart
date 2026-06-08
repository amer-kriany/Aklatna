class AppuserEntity {
  final String id;
  final String userName;
  final String? email;
  final String? phone;
  final bool isPhoneProtected;
  AppuserEntity({
    required this.id,
    required this.userName,
    required this.email,
    required this.phone,
    required this.isPhoneProtected,
  });
}
