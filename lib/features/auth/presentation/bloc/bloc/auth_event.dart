part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String phone;
  final String password;
  final String username;

  const SignUpEvent({required this.email, required this.phone, required this.password, required this.username});

  @override
  List<Object> get props => [email,password,username, phone, ];
}
class VerifySignUpOtpEvent extends AuthEvent {
  final String email;
  final String token;
  const VerifySignUpOtpEvent({required this.email, required this.token});
  @override
  List<Object> get props => [email, token];
}
class ResendSignUpOtpEvent extends AuthEvent {
  final String email;
  const ResendSignUpOtpEvent({required this.email});
  @override
  List<Object> get props => [email];
}

class RequestPasswordResetEvent extends AuthEvent {
  final String email;
  const RequestPasswordResetEvent({required this.email});
  @override
  List<Object> get props => [email];
}

class VerifyRecoveryOtpEvent extends AuthEvent {
  final String email;
  final String token;
  const VerifyRecoveryOtpEvent({required this.email, required this.token});
  @override
  List<Object> get props => [email, token];
}

class UpdatePasswordEvent extends AuthEvent {
  final String newPassword;
  const UpdatePasswordEvent({required this.newPassword});
  @override
  List<Object> get props => [newPassword];
}

class SignInEvent extends AuthEvent {
  final String? email;
  final String? phone;
  final String password;

  const SignInEvent({this.email, this.phone, required this.password});

  @override
  List<Object> get props => [email ?? '', phone ?? '', password];
}

class SignOutEvent extends AuthEvent {}

class GetCurrentUserEvent extends AuthEvent {}

