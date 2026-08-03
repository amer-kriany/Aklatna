// injection_container.dart

import 'package:get_it/get_it.dart';

import 'package:aklatna/features/auth/data/datasources/auth_datasource.dart';
import 'package:aklatna/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:aklatna/features/auth/domain/repositories/auth_repository.dart';

import 'package:aklatna/features/auth/domain/usecases/currentuser_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/requestPasswordResetUsecase.dart';
import 'package:aklatna/features/auth/domain/usecases/resendSignUpOtpUsecase.dart';
import 'package:aklatna/features/auth/domain/usecases/signin_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/signup_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/singout_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/updatePasswordUsecase.dart';
import 'package:aklatna/features/auth/domain/usecases/verifyRecoveryOtpUsecase.dart';
import 'package:aklatna/features/auth/domain/usecases/verifySignUpOtpUsecase.dart';

import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';

final sl = GetIt.instance;

void setupInjection() {
  // ============================================================
  // DATASOURCE
  // ============================================================

  sl.registerLazySingleton<AuthDatasource>(
    () => AuthDatasource(),
  );

  // ============================================================
  // REPOSITORY
  // ============================================================

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      datasource: sl<AuthDatasource>(),
    ),
  );

  // ============================================================
  // USECASES
  // ============================================================

  sl.registerLazySingleton<SignUpUsecase>(
    () => SignUpUsecase(
      repository: sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<SigninUsecase>(
    () => SigninUsecase(
      repository: sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<SingoutUsecase>(
    () => SingoutUsecase(
      repository: sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<CurrentuserUsecase>(
    () => CurrentuserUsecase(
      repository: sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<Verifysignupotpusecase>(
    () => Verifysignupotpusecase(
      repo: sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<Requestpasswordresetusecase>(
    () => Requestpasswordresetusecase(
      repo: sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<VerifyRecoveryOtpUsecase>(
    () => VerifyRecoveryOtpUsecase(
      repository: sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<UpdatePasswordUsecase>(
    () => UpdatePasswordUsecase(
      repository: sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<ResendSignUpOtpUsecase>(
    () => ResendSignUpOtpUsecase(
      repository: sl<AuthRepository>(),
    ),
  );

  // ============================================================
  // AUTH BLOC
  // ============================================================

  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      signUpUsecase: sl<SignUpUsecase>(),
      signInUsecase: sl<SigninUsecase>(),
      currentUserUsecase: sl<CurrentuserUsecase>(),
      singoutUsecase: sl<SingoutUsecase>(),

      verifysignupotpusecase:
          sl<Verifysignupotpusecase>(),

      requestpasswordresetusecase:
          sl<Requestpasswordresetusecase>(),

      verifyRecoveryOtpUsecase:
          sl<VerifyRecoveryOtpUsecase>(),

      updatePasswordUsecase:
          sl<UpdatePasswordUsecase>(),

      resendSignUpOtpUsecase:
          sl<ResendSignUpOtpUsecase>(), 
    ),
  );
}