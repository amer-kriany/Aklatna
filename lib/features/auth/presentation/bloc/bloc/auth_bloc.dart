import 'package:aklatna/core/errors/authErrorMapper.dart';
import 'package:aklatna/features/auth/domain/entities/appuser_entity.dart';
import 'package:aklatna/features/auth/domain/usecases/currentuser_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/signin_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/signup_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/singout_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUsecase signUpUsecase;
  final SigninUsecase signInUsecase;
  final CurrentuserUsecase currentUserUsecase;
  final SingoutUsecase signOutUsecase;

  AuthBloc({
    required this.signUpUsecase,
    required this.signInUsecase,
    required this.currentUserUsecase,
    required this.signOutUsecase,
  }) : super(AuthInitial()) {
    on<SignUpEvent>(_signUp);
    on<SignInEvent>(_signIn);
    on<SignOutEvent>(_signOut);
    on<GetCurrentUserEvent>(_getCurrentUser);
  }

  // sign up
  Future<void> _signUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final user = await signUpUsecase(
        event.email,
        event.password,
        event.username,
        event.phone,
      );
      emit(AuthAuthenticated(user: user));
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
      await signOutUsecase();
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