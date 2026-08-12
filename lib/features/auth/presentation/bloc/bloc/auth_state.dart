part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// ============================================================
// INITIAL
// ============================================================

final class AuthInitial extends AuthState {}

// ============================================================
// LOADING
// ============================================================

final class AuthLoading extends AuthState {}

// ============================================================
// AUTHENTICATED
// ============================================================

final class AuthAuthenticated extends AuthState {
  final AppuserEntity user;

  const AuthAuthenticated({
    required this.user,
  });

  @override
  List<Object> get props => [
        user,
      ];
}

// ============================================================
// UNAUTHENTICATED
// ============================================================

final class AuthUnauthenticated extends AuthState {}

// ============================================================
// ERROR
// ============================================================

final class AuthError extends AuthState {
  final String message;

  const AuthError({
    required this.message,
  });

  @override
  List<Object> get props => [
        message,
      ];
}

// ============================================================
// SIGN UP OTP SENT
// ============================================================

class AuthSignUpOtpSent extends AuthState {
  final String email;

  const AuthSignUpOtpSent({
    required this.email,
  });

  @override
  List<Object> get props => [
        email,
      ];
}

// ============================================================
// PASSWORD RESET EMAIL SENT
// ============================================================

class AuthPasswordResetEmailSent extends AuthState {
  final String email;

  const AuthPasswordResetEmailSent({
    required this.email,
  });

  @override
  List<Object> get props => [
        email,
      ];
}

// ============================================================
// RECOVERY VERIFIED
// ============================================================

class AuthRecoveryVerified extends AuthState {}

// ============================================================
// PASSWORD UPDATED
// ============================================================

class AuthPasswordUpdated extends AuthState {}