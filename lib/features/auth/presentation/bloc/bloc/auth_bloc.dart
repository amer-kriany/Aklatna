import 'package:aklatna/core/errors/authErrorMapper.dart';
import 'package:aklatna/features/auth/domain/entities/appuser_entity.dart';
import 'package:aklatna/features/auth/domain/usecases/currentuser_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/requestPasswordResetUsecase.dart';
import 'package:aklatna/features/auth/domain/usecases/resendSignUpOtpUsecase.dart';
import 'package:aklatna/features/auth/domain/usecases/signin_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/signup_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/singout_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/updatePasswordUsecase.dart';
import 'package:aklatna/features/auth/domain/usecases/verifyRecoveryOtpUsecase.dart';
import 'package:aklatna/features/auth/domain/usecases/verifySignUpOtpUsecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUsecase signUpUsecase;
  final SigninUsecase signInUsecase;
  final SingoutUsecase singoutUsecase;
  final CurrentuserUsecase currentUserUsecase;
  final VerifyRecoveryOtpUsecase verifyRecoveryOtpUsecase;
  final Verifysignupotpusecase verifysignupotpusecase;
  final Requestpasswordresetusecase requestpasswordresetusecase;
  final UpdatePasswordUsecase updatePasswordUsecase;
  final ResendSignUpOtpUsecase resendSignUpOtpUsecase;

  AuthBloc({
    required this.signUpUsecase,
  required this.signInUsecase,
  required this.currentUserUsecase,
  required this.singoutUsecase,
  required this.verifysignupotpusecase,
  required this.requestpasswordresetusecase,
  required this.verifyRecoveryOtpUsecase,
  required this.updatePasswordUsecase, required this.resendSignUpOtpUsecase,
  }) : super(AuthInitial()) {
    on<SignUpEvent>(_signUp);
  on<SignInEvent>(_signIn);
  on<SignOutEvent>(_signOut);
  on<GetCurrentUserEvent>(_getCurrentUser);
  on<VerifySignUpOtpEvent>(_verifySignUpOtp);
  on<ResendSignUpOtpEvent>(_resendSignUpOtp);
  on<RequestPasswordResetEvent>(_requestPasswordReset);
  on<VerifyRecoveryOtpEvent>(_verifyRecoveryOtp);
  on<UpdatePasswordEvent>(_updatePassword);
  }

  // sign up — now just triggers the OTP email, doesn't authenticate yet
Future<void> _signUp(SignUpEvent event, Emitter<AuthState> emit) async {
  try {
    emit(AuthLoading());
    await signUpUsecase(event.email, event.password, event.username, event.phone);
    emit(AuthSignUpOtpSent(email: event.email));
  } catch (e) {
    emit(AuthError(message: AuthErrorMapper.map(e)));
  }
}
Future<void> _verifySignUpOtp(VerifySignUpOtpEvent event, Emitter<AuthState> emit) async {
  try {
    emit(AuthLoading());
    final user = await verifysignupotpusecase(event.email, event.token);
    emit(AuthAuthenticated(user: user));
  } catch (e) {
    emit(AuthError(message: AuthErrorMapper.map(e)));
  }
}

Future<void> _resendSignUpOtp(ResendSignUpOtpEvent event, Emitter<AuthState> emit) async {
  try {
    await resendSignUpOtpUsecase(event.email);
  } catch (e) {
    emit(AuthError(message: AuthErrorMapper.map(e)));
  }
}

Future<void> _requestPasswordReset(RequestPasswordResetEvent event, Emitter<AuthState> emit) async {
  try {
    emit(AuthLoading());
    await requestpasswordresetusecase(event.email);
    emit(AuthPasswordResetEmailSent(email: event.email));
  } catch (e) {
    emit(AuthError(message: AuthErrorMapper.map(e)));
  }
}

Future<void> _verifyRecoveryOtp(VerifyRecoveryOtpEvent event, Emitter<AuthState> emit) async {
  try {
    emit(AuthLoading());
    await verifyRecoveryOtpUsecase(event.email, event.token);
    emit(AuthRecoveryVerified());
  } catch (e) {
    emit(AuthError(message: AuthErrorMapper.map(e)));
  }
}

Future<void> _updatePassword(UpdatePasswordEvent event, Emitter<AuthState> emit) async {
  try {
    emit(AuthLoading());
    await updatePasswordUsecase(event.newPassword);
    emit(AuthPasswordUpdated());
  } catch (e) {
    emit(AuthError(message: AuthErrorMapper.map(e)));
  }
}

  // sign in
  Future<void> _signIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final user = await signInUsecase(event.email, event.password, event.phone);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: AuthErrorMapper.map(e)));
    }
  }

  // sign out
  Future<void> _signOut(SignOutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      await singoutUsecase();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: AuthErrorMapper.map(e)));
    }
  }

  // current user
  Future<void> _getCurrentUser(
    GetCurrentUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final user = await currentUserUsecase();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      // "No user found" is thrown by our own repository whenever
      // there's simply no logged-in session yet — completely normal
      // at cold start for a logged-out user, not a real error. Showing
      // an error snackbar for this would scare every first-time user
      // the moment they open the app.
      if (e.toString().contains('No user found')) {
        emit(AuthUnauthenticated());
        return;
      }

      emit(AuthError(message: AuthErrorMapper.map(e)));
    }
  }
}