import 'package:aklatna/core/router/app_router.dart';
import 'package:aklatna/features/auth/data/datasources/auth_datasource.dart';
import 'package:aklatna/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aklatna/features/auth/domain/usecases/currentuser_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/signin_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/signup_usecase.dart';
import 'package:aklatna/features/auth/domain/usecases/singout_usecase.dart';
import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:aklatna/features/home/data/datasources/business_datasrouce.dart';
import 'package:aklatna/features/home/data/repository/businessRepoImp.dart';
import 'package:aklatna/features/home/domain/usecases/getbusiness_usecase.dart';
import 'package:aklatna/features/home/domain/usecases/searchBusinessesUseCase.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';

import 'package:aklatna/features/menu/data/data_source/menuDataSource.dart';
import 'package:aklatna/features/menu/data/repository/menuRepoImp.dart';
import 'package:aklatna/features/menu/domain/usecases/getCategoriesUseCase.dart';
import 'package:aklatna/features/menu/domain/usecases/getItemsUsecase.dart';
import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:aklatna/features/profile/data/datasource/profile_datasource.dart';
import 'package:aklatna/features/profile/data/repository/profileRepoImp.dart';
import 'package:aklatna/features/profile/domain/usecases/getProfilesUsecase.dart';
import 'package:aklatna/features/profile/domain/usecases/updateProfileUsecase.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  final getMenuDataSource = Menudatasource();
  final profileDatasource = ProfileDatasource();
  // repositories
  final repository = AuthRepositoryImpl(datasource: authDatasource);
  final businessRepository = Businessrepoimp(
    businessDatasrouce: getBusinessDatasource,
  );
  final menuRepo = Menurepoimp(menudatasource: getMenuDataSource);
  final profileRepo = Profilerepoimp(profileDatasource: profileDatasource);
  //use cases
  final signUpUsecase = SignUpUsecase(repository: repository);
  final signInUsecase = SigninUsecase(repository: repository);
  final currentUserUsecase = CurrentuserUsecase(repository: repository);
  final signOutUsecase = SingoutUsecase(repository: repository);
  final getBusinessUsecase = GetbusinessUsecase(repository: businessRepository);
  final searchBusinessesusecase = Searchbusinessesusecase(businessrepoimp: businessRepository);
  final getcategoriesusecase = Getcategoriesusecase(repo: menuRepo);
  final getitemsusecase = Getitemsusecase(repo: menuRepo);
  final getprofilesusecase = Getprofilesusecase(repo: profileRepo);
  final updateprofileusecase = Updateprofileusecase(repo: profileRepo);
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
          create: (context) =>
              BusinessBloc(getBusinessUsecase: getBusinessUsecase, searchbusinessesusecase: searchBusinessesusecase),
        ),
        BlocProvider(
          create: (context) => MenuBloc(
            menuCategoriesusecase: getcategoriesusecase,
            menuItemsusecase: getitemsusecase,
          ),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(getProfilesUsecase: getprofilesusecase, updateProfileUsecase: updateprofileusecase),
        )
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'Aklatna',
      theme: AppTheme.lightTheme,
    );
  }
}
