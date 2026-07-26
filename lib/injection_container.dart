// injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:aklatna/features/auth/data/datasources/auth_datasource.dart';
import 'package:aklatna/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aklatna/features/auth/domain/usecases/currentuser_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/signin_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/signup_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/singout_usecase.dart';
import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';

final sl = GetIt.instance;

void setupInjection() {
  sl.registerLazySingleton(() => AuthDatasource());
  sl.registerLazySingleton(() => AuthRepositoryImpl(datasource: sl()));
  sl.registerLazySingleton(() => SignUpUsecase(repository: sl()));
  sl.registerLazySingleton(() => SigninUsecase(repository: sl()));
  sl.registerLazySingleton(() => CurrentuserUsecase(repository: sl()));
  sl.registerLazySingleton(() => SingoutUsecase(repository: sl()));
  sl.registerLazySingleton(() => AuthBloc(
        signUpUsecase: sl(),
        signInUsecase: sl(),
        currentUserUsecase: sl(),
        signOutUsecase: sl(),
      )..add(GetCurrentUserEvent())); // dispatch session check immediately on creation
}