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
  Future<AppuserEntity> _signUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    return await signUpUsecase(
      event.email,
      event.password,
      event.username,
      event.phone,
    );
  }

  // sign in
  Future<AppuserEntity> _signIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    return await signInUsecase(event.email, event.password, event.phone);
  }

  // sign out
  Future<void> _signOut(SignOutEvent event, Emitter<AuthState> emit) async {
    await signOutUsecase();
  }

  // current user
  Future<AppuserEntity?> _getCurrentUser(
    GetCurrentUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    return await currentUserUsecase();
  }
}
