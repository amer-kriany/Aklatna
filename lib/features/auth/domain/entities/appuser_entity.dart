import 'package:equatable/equatable.dart';

class AppuserEntity extends Equatable {
  final String id;
  final String userName;
  final String? email;
  final String? phone;
  final bool isPhoneverified;

  const AppuserEntity({
    required this.id,
    required this.userName,
    this.email,
    this.phone,
    required this.isPhoneverified,
  });

  @override
  List<Object?> get props => [id, userName, email, phone, isPhoneverified];
}