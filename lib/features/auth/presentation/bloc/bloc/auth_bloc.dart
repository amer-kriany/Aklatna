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
      emit(AuthError(message: e.toString()));
    }
  }

  // sign in
  Future<void> _signIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    try{
      emit(AuthLoading());
    final user = await signInUsecase(event.email, event.password, event.phone);
    emit(AuthAuthenticated(user: user));
    }catch(e){
      emit(AuthError(message: e.toString()));
    }
    
  }

  // sign out
  Future<void> _signOut(SignOutEvent event, Emitter<AuthState> emit) async {
    try{
      emit(AuthLoading());
    await signOutUsecase();
    emit(AuthUnauthenticated());
    }catch(e){
      emit(AuthError(message: e.toString()));
    }
  }

  // current user
  Future<void> _getCurrentUser(
    GetCurrentUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    try{
      emit(AuthLoading());
    final user =  await currentUserUsecase();
     emit(AuthAuthenticated(user: user));
    }catch(e){
      emit(AuthError(message: e.toString()));
      }
  }
}
