import 'package:aklatna/features/addOnes/data/datasource/addOnesDataSource.dart';
import 'package:aklatna/features/addOnes/data/repository/addOnesRepoImp.dart';
import 'package:aklatna/features/addOnes/domain/repository/addOnesRepo.dart';
import 'package:aklatna/features/addOnes/domain/useCases/getAddOnesUseCase.dart';
import 'package:aklatna/features/addOnes/presentation/bloc/add_ones_bloc.dart';
import 'package:aklatna/features/addresses/data/dataSource/addressDataSource.dart';
import 'package:aklatna/features/addresses/data/repository/addressRepoImp.dart';
import 'package:aklatna/features/addresses/domain/repository/addressRepo.dart';
import 'package:aklatna/features/addresses/domain/usecases/useCases.dart';
import 'package:aklatna/features/addresses/presentation/bloc/address_bloc.dart';
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
import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/favorit/data/ReposityrImp.dart/favoritRepoImp.dart';
import 'package:aklatna/features/favorit/data/datasource/favoriteDataSource.dart';
import 'package:aklatna/features/favorit/domain/repository/favoritRepository.dart';
import 'package:aklatna/features/favorit/domain/useCases/favoriteUseCase.dart';
import 'package:aklatna/features/favorit/presentation/bloc/favorite_bloc.dart';
import 'package:aklatna/features/home/data/datasources/business_datasrouce.dart';
import 'package:aklatna/features/home/data/repository/businessRepoImp.dart';
import 'package:aklatna/features/home/domain/repository/businessRepo.dart';
import 'package:aklatna/features/home/domain/usecases/getbusiness_usecase.dart';
import 'package:aklatna/features/home/domain/usecases/searchBusinessesUseCase.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/job_listings/data/dataSource/job_datasource.dart';
import 'package:aklatna/features/job_listings/data/repository/job_repoImp.dart';
import 'package:aklatna/features/job_listings/domain/repository/jobRepo.dart';
import 'package:aklatna/features/job_listings/domain/usecases/get_jobs_usecase.dart';
import 'package:aklatna/features/job_listings/presentation/bloc/job_bloc.dart';
import 'package:aklatna/features/menu/data/data_source/menuDataSource.dart';
import 'package:aklatna/features/menu/data/repository/menuRepoImp.dart';
import 'package:aklatna/features/menu/domain/repository/menuRepo.dart';
import 'package:aklatna/features/menu/domain/usecases/getCategoriesUseCase.dart';
import 'package:aklatna/features/menu/domain/usecases/getItemsUsecase.dart';
import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:aklatna/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:aklatna/features/orders/data/repositories/order_repository_impl.dart';
import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';
import 'package:aklatna/features/orders/domain/usecases/accept_order_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/complete_order_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/getDriverOrdersUseCase.dart';
import 'package:aklatna/features/orders/domain/usecases/get_available_orders_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/get_customer_orders_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/mark_out_for_delivery_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/orderStatusUseCase.dart';
import 'package:aklatna/features/orders/domain/usecases/place_order_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/watchAvailableOrderUsecase.dart';
import 'package:aklatna/features/orders/domain/usecases/watchDriverOrder.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aklatna/features/profile/data/datasource/profile_datasource.dart';
import 'package:aklatna/features/profile/data/repository/profileRepoImp.dart';
import 'package:aklatna/features/profile/domain/usecases/getProfilesUsecase.dart';
import 'package:aklatna/features/profile/domain/usecases/updateProfilePhotoUseCase.dart';
import 'package:aklatna/features/profile/domain/usecases/updateProfileUsecase.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:aklatna/features/promotions/data/dataSource/promotionDataSource.dart';
import 'package:aklatna/features/promotions/data/repository/promotionsRepoImp.dart';
import 'package:aklatna/features/promotions/domain/repository/promotionsRepo.dart';
import 'package:aklatna/features/promotions/domain/usecases/GetPromotionsMapUseCase.dart';
import 'package:aklatna/features/promotions/domain/usecases/promotionsUseCase.dart';
import 'package:aklatna/features/promotions/presentaion/bloc/promotions_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void setupInjection() {
  // ============================================================
  // AUTH
  // ============================================================
  sl.registerLazySingleton<AuthDatasource>(() => AuthDatasource());

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(datasource: sl<AuthDatasource>()),
  );

  sl.registerLazySingleton<SignUpUsecase>(
    () => SignUpUsecase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SigninUsecase>(
    () => SigninUsecase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SingoutUsecase>(
    () => SingoutUsecase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<CurrentuserUsecase>(
    () => CurrentuserUsecase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<Verifysignupotpusecase>(
    () => Verifysignupotpusecase(repo: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<Requestpasswordresetusecase>(
    () => Requestpasswordresetusecase(repo: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifyRecoveryOtpUsecase>(
    () => VerifyRecoveryOtpUsecase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<UpdatePasswordUsecase>(
    () => UpdatePasswordUsecase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ResendSignUpOtpUsecase>(
    () => ResendSignUpOtpUsecase(repository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      signUpUsecase: sl<SignUpUsecase>(),
      signInUsecase: sl<SigninUsecase>(),
      currentUserUsecase: sl<CurrentuserUsecase>(),
      singoutUsecase: sl<SingoutUsecase>(),
      verifysignupotpusecase: sl<Verifysignupotpusecase>(),
      requestpasswordresetusecase: sl<Requestpasswordresetusecase>(),
      verifyRecoveryOtpUsecase: sl<VerifyRecoveryOtpUsecase>(),
      updatePasswordUsecase: sl<UpdatePasswordUsecase>(),
      resendSignUpOtpUsecase: sl<ResendSignUpOtpUsecase>(),
    ),
  );

  // ============================================================
  // PROFILE
  // ============================================================
  sl.registerLazySingleton<ProfileDatasource>(() => ProfileDatasource());

  sl.registerLazySingleton<Profilerepoimp>(
    () => Profilerepoimp(profileDatasource: sl<ProfileDatasource>()),
  );

  sl.registerLazySingleton<Getprofilesusecase>(
    () => Getprofilesusecase(repo: sl<Profilerepoimp>()),
  );
  sl.registerLazySingleton<Updateprofileusecase>(
    () => Updateprofileusecase(repo: sl<Profilerepoimp>()),
  );
  sl.registerLazySingleton<Updateprofilephotousecase>(
    () => Updateprofilephotousecase(repo: sl<Profilerepoimp>()),
  );

  sl.registerLazySingleton<ProfileBloc>(
    () => ProfileBloc(
      getProfilesUsecase: sl<Getprofilesusecase>(),
      updateProfileUsecase: sl<Updateprofileusecase>(),
      updateprofilephotousecase: sl<Updateprofilephotousecase>(),
    ),
  );

  // ============================================================
  // DATASOURCES (rest of app)
  // ============================================================
  sl.registerLazySingleton(() => BusinessDatasrouce());
  sl.registerLazySingleton(() => Menudatasource());
  sl.registerLazySingleton(() => FavoriteDatasource());
  sl.registerLazySingleton(() => OrderRemoteDatasource());
  sl.registerLazySingleton(() => JobDatasource());
  sl.registerLazySingleton(() => AddressDatasource());
  sl.registerLazySingleton(() => Promotiondatasource());

  // ============================================================
  // REPOSITORIES (rest of app)
  // ============================================================
  sl.registerLazySingleton<Promotionsrepo>(
    () => Promotionsrepoimp(promotiondatasource: sl()),
  );
  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(orderRemoteDatasource: sl()),
  );
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton<Jobrepo>(() => JobRepoimp(jobDatasource: sl()));
  sl.registerLazySingleton<Businessrepo>(
    () => Businessrepoimp(businessDatasrouce: sl()),
  );
  sl.registerLazySingleton<Menurepo>(() => Menurepoimp(menudatasource: sl()));

  // ============================================================
  // USECASES (rest of app)
  // ============================================================
  sl.registerLazySingleton(() => GetPromotionsUseCase(sl()));
  sl.registerLazySingleton(() => GetPromotionsMapUseCase(repo: sl()));
  sl.registerLazySingleton(
    () => GetCustomerOrdersUseCase(orderRepositoryImpl: sl()),
  );
  sl.registerLazySingleton(() => GetDriverOrdersUseCase(repository: sl()));
  sl.registerLazySingleton(() => WatchAvailableOrdersUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetAddressesUsecase(repo: sl()));
  sl.registerLazySingleton(() => AddAddressUsecase(repo: sl()));
  sl.registerLazySingleton(() => DeleteAddressUsecase(repo: sl()));
  sl.registerLazySingleton(() => SetDefaultAddressUsecase(repo: sl()));
  sl.registerLazySingleton(() => GetJobsUsecase(jobRepo: sl()));
  sl.registerLazySingleton(() => Orderstatususecase(orderRepositoryImpl: sl()));
  sl.registerLazySingleton(() => PlaceOrderUsecase(orderRepositoryImpl: sl()));
  sl.registerLazySingleton(() => GetAvailableOrdersUseCase(repository: sl()));
  sl.registerLazySingleton(() => AcceptOrderUseCase(repository: sl()));
  sl.registerLazySingleton(() => MarkOutForDeliveryUseCase(repository: sl()));
  sl.registerLazySingleton(() => CompleteOrderUseCase(repository: sl()));
  sl.registerLazySingleton(() => WatchDriverOrdersUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetbusinessUsecase(repository: sl()));
 
  sl.registerLazySingleton(
    () => Searchbusinessesusecase(businessrepo: sl()),
  );
  sl.registerLazySingleton(() => Getcategoriesusecase(repo: sl()));
  sl.registerLazySingleton(() => Getitemsusecase(repo: sl()));
  sl.registerLazySingleton(() => AddFavoriteUsecase(repo: sl()));
  sl.registerLazySingleton(() => RemoveFavoriteUsecase(repo: sl()));
  sl.registerLazySingleton(() => GetFavoriteIdsUsecase(repo: sl()));
  sl.registerLazySingleton(() => GetFavoriteItemsUsecase(repo: sl()));

  // ============================================================
  // BLOCS (rest of app)
  // ============================================================
  sl.registerFactory(
    () => BusinessBloc(getBusinessUsecase: sl(), searchbusinessesusecase: sl()),
  );
  sl.registerFactory(
    () =>
        PromotionsBloc(promotionsUseCase: sl(), getPromotionsMapUseCase: sl()),
  );
  sl.registerFactory(
    () => AddressBloc(
      getAddressesUsecase: sl(),
      addAddressUsecase: sl(),
      deleteAddressUsecase: sl(),
      setDefaultAddressUsecase: sl(),
    ),
  );
  sl.registerFactory(() => JobBloc(getJobsUsecase: sl()));
  sl.registerFactory(
    () => FavoriteBloc(
      addFavoriteUsecase: sl(),
      removeFavoriteUsecase: sl(),
      getFavoriteIdsUsecase: sl(),
      getFavoriteItemsUsecase: sl(),
    ),
  );
  sl.registerFactory(
    () => MenuBloc(menuCategoriesusecase: sl(), menuItemsusecase: sl()),
  );
  sl.registerFactory(() => CartBloc());
  sl.registerFactory(
    () => OrderBloc(
      watchOrderStatusUsecase: sl(),
      placeOrderUsecase: sl(),
      customerOrdersUsecase: sl(),
      getAvailableOrdersUseCase: sl(),
      acceptOrderUseCase: sl(),
      markOutForDeliveryUseCase: sl(),
      completeOrderUseCase: sl(),
      getDriverOrdersUseCase: sl(),
      watchAvailableOrdersUseCase: sl(),
      watchDriverOrdersUseCase: sl(),
    ),
  );
  // ============================================================
  // ADDONS
  // ============================================================
  sl.registerLazySingleton(() => Addonesdatasource());
  sl.registerLazySingleton<AddonRepository>(
    () => AddonRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton(() => GetAddonsUsecase(repo: sl()));
  sl.registerFactory(() => AddonBloc(getAddonsUsecase: sl()));
}