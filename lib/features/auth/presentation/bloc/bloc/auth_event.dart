part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// ============================================================
// SIGN UP
// ============================================================

class SignUpEvent extends AuthEvent {
  final String email;
  final String phone;
  final String password;
  final String username;

  const SignUpEvent({
    required this.email,
    required this.phone,
    required this.password,
    required this.username,
  });

  @override
  List<Object> get props => [
        email,
        phone,
        password,
        username,
      ];
}

// ============================================================
// VERIFY SIGN UP OTP
// ============================================================

class VerifySignUpOtpEvent extends AuthEvent {
  final String email;
  final String token;

  const VerifySignUpOtpEvent({
    required this.email,
    required this.token,
  });

  @override
  List<Object> get props => [
        email,
        token,
      ];
}

// ============================================================
// RESEND SIGN UP OTP
// ============================================================

class ResendSignUpOtpEvent extends AuthEvent {
  final String email;

  const ResendSignUpOtpEvent({
    required this.email,
  });

  @override
  List<Object> get props => [
        email,
      ];
}

// ============================================================
// REQUEST PASSWORD RESET
// ============================================================

class RequestPasswordResetEvent extends AuthEvent {
  final String email;

  const RequestPasswordResetEvent({
    required this.email,
  });

  @override
  List<Object> get props => [
        email,
      ];
}

// ============================================================
// VERIFY RECOVERY OTP
// ============================================================

class VerifyRecoveryOtpEvent extends AuthEvent {
  final String email;
  final String token;

  const VerifyRecoveryOtpEvent({
    required this.email,
    required this.token,
  });

  @override
  List<Object> get props => [
        email,
        token,
      ];
}

// ============================================================
// UPDATE PASSWORD
// ============================================================

class UpdatePasswordEvent extends AuthEvent {
  final String newPassword;

  const UpdatePasswordEvent({
    required this.newPassword,
  });

  @override
  List<Object> get props => [
        newPassword,
      ];
}

// ============================================================
// SIGN IN
// ============================================================

class SignInEvent extends AuthEvent {
  final String? email;
  final String? phone;
  final String password;

  const SignInEvent({
    this.email,
    this.phone,
    required this.password,
  });

  @override
  List<Object> get props => [
        email ?? '',
        phone ?? '',
        password,
      ];
}

// ============================================================
// SIGN OUT
// ============================================================

class SignOutEvent extends AuthEvent {}

// ============================================================
// CURRENT USER
// ============================================================

class GetCurrentUserEvent extends AuthEvent {}