part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignUpEvent extends AuthEvent {
  final String? email;
  final String phone;
  final String password;
  final String username;

  const SignUpEvent({this.email, required this.phone, required this.password, required this.username});

  @override
  List<Object> get props => [email ?? '', phone, password, username];
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
