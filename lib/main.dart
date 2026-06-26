import 'package:aklatna/features/auth/data/datasources/auth_datasource.dart';
import 'package:aklatna/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aklatna/features/auth/domain/usecases/currentuser_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/signin_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/signup_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/singout_usecase.dart';
import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:aklatna/features/auth/presentation/pages/login_page.dart';
import 'package:aklatna/features/home/data/datasources/business_datasrouce.dart';
import 'package:aklatna/features/home/data/repository/businessRepoImp.dart';
import 'package:aklatna/features/home/domain/usecases/getbusiness_usecase.dart';
import 'package:aklatna/features/home/presentation/cubit/business_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shimmer/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aklatna/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  // data sources
  final authDatasource = AuthDatasource();
  final getBusinessDatasource = BusinessDatasrouce();
  // repositories
  final repository = AuthRepositoryImpl(datasource: authDatasource);
  final businessRepository = Businessrepoimp(businessDatasrouce: getBusinessDatasource);
  //use cases
  final signUpUsecase = SignUpUsecase(repository: repository);
  final signInUsecase = SigninUsecase(repository: repository);
  final currentUserUsecase = CurrentuserUsecase(repository: repository);
  final signOutUsecase = SingoutUsecase(repository: repository);
  final getBusinessUsecase = GetbusinessUsecase(repository: businessRepository);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            signUpUsecase: signUpUsecase,
            signInUsecase: signInUsecase,
            currentUserUsecase: currentUserUsecase,
            signOutUsecase: signOutUsecase,
          ),
        ),
        BlocProvider(
          create: (context) => BusinessCubit(getBusinessUsecase),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aklatna',
      theme: AppTheme.lightTheme,
      home:  Scaffold(body: Container()),
    );
  }
}
