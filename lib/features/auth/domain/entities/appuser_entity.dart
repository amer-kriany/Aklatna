class AppuserEntity {
  final String id;
  final String userName;
  final String? email;
  final String? phone;
  final bool isPhoneverified;
  AppuserEntity({
    required this.id,
    required this.userName,
     this.email,
   this.phone,
    required this.isPhoneverified,
  });
}
