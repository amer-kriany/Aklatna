import 'package:aklatna/core/router/app_router.dart';
import 'package:aklatna/core/router/MainShell.dart';
import 'package:aklatna/core/services/onboarding_service.dart';
import 'package:aklatna/features/addresses/data/dataSource/addressDataSource.dart';
import 'package:aklatna/features/addresses/data/repository/addressRepoImp.dart';
import 'package:aklatna/features/addresses/domain/usecases/useCases.dart';
import 'package:aklatna/features/addresses/presentation/bloc/address_bloc.dart';
import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/favorit/data/ReposityrImp.dart/favoritRepoImp.dart';
import 'package:aklatna/features/favorit/data/datasource/favoriteDataSource.dart';
import 'package:aklatna/features/favorit/domain/useCases/favoriteUseCase.dart';
import 'package:aklatna/features/favorit/presentation/bloc/favorite_bloc.dart';
import 'package:aklatna/features/home/data/datasources/business_datasrouce.dart';
import 'package:aklatna/features/home/data/repository/businessRepoImp.dart';
import 'package:aklatna/features/home/domain/usecases/getbusiness_usecase.dart';
import 'package:aklatna/features/home/domain/usecases/searchBusinessesUseCase.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/job_listings/data/dataSource/job_datasource.dart';
import 'package:aklatna/features/job_listings/data/repository/job_repoImp.dart';
import 'package:aklatna/features/job_listings/domain/usecases/get_jobs_usecase.dart';
import 'package:aklatna/features/job_listings/presentation/bloc/job_bloc.dart';
import 'package:aklatna/features/menu/data/data_source/menuDataSource.dart';
import 'package:aklatna/features/menu/data/repository/menuRepoImp.dart';
import 'package:aklatna/features/menu/domain/usecases/getCategoriesUseCase.dart';
import 'package:aklatna/features/menu/domain/usecases/getItemsUsecase.dart';
import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:aklatna/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:aklatna/features/orders/data/repositories/order_repository_impl.dart';
import 'package:aklatna/features/orders/domain/usecases/get_customer_orders_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/orderStatusUseCase.dart';
import 'package:aklatna/features/orders/domain/usecases/place_order_usecase.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:aklatna/features/profile/data/datasource/profile_datasource.dart';
import 'package:aklatna/features/profile/data/repository/profileRepoImp.dart';
import 'package:aklatna/features/profile/domain/usecases/getProfilesUsecase.dart';
import 'package:aklatna/features/profile/domain/usecases/updateProfilePhotoUseCase.dart';
import 'package:aklatna/features/profile/domain/usecases/updateProfileUsecase.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:aklatna/features/promotions/data/dataSource/promotionDataSource.dart';
import 'package:aklatna/features/promotions/data/repository/promotionsRepoImp.dart';
import 'package:aklatna/features/promotions/domain/usecases/promotionsUseCase.dart';
import 'package:aklatna/features/promotions/presentaion/bloc/promotions_bloc.dart';
import 'package:aklatna/features/review/data/datasource/reviewRemoteDatasource.dart';
import 'package:aklatna/features/review/data/repository/reviewRepoImp.dart';
import 'package:aklatna/features/review/presentaion/pages/ratingPage.dart';
import 'package:aklatna/injection_container.dart';
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
  setupInjection();

  // Check if user has already completed onboarding
  final bool hasCompletedOnboarding = await OnboardingService.isCompleted();

  // Data sources
  final getBusinessDatasource = BusinessDatasrouce();
  final getMenuDataSource = Menudatasource();
  final profileDatasource = ProfileDatasource();
  final favoriteDatasource = FavoriteDatasource();
  final orderRemoteDatasource = OrderRemoteDatasource();
  final jobDatasource = JobDatasource();
  final addressDatasource = AddressDatasource();
  final promotiondatasource = Promotiondatasource();

  // Repositories
  final promotionrepo = Promotionsrepoimp(
    promotiondatasource: promotiondatasource,
  );
  final favoriteRepo = FavoriteRepositoryImpl(datasource: favoriteDatasource);
  final orderRepo = OrderRepositoryImpl(
    orderRemoteDatasource: orderRemoteDatasource,
  );
  final addressrepo = AddressRepositoryImpl(datasource: addressDatasource);
  final jobRepo = JobRepoimp(jobDatasource: jobDatasource);
  final businessRepository = Businessrepoimp(
    businessDatasrouce: getBusinessDatasource,
  );
  final menuRepo = Menurepoimp(menudatasource: getMenuDataSource);
  final profileRepo = Profilerepoimp(profileDatasource: profileDatasource);

  // Use cases
  final getpromotions = GetPromotionsUseCase(promotionrepo);
  final getCostomerOrdersUseCase = GetCustomerOrdersUseCase(
    orderRepositoryImpl: orderRepo,
  );
  final getAddressUsecase = GetAddressesUsecase(repo: addressrepo);
  final addAddressUsecase = AddAddressUsecase(repo: addressrepo);
  final deleteAddressUsecase = DeleteAddressUsecase(repo: addressrepo);
  final setDefaultAddressUsecase = SetDefaultAddressUsecase(repo: addressrepo);
  final getJobsUsecase = GetJobsUsecase(jobRepoimp: jobRepo);
  final orderstatususecase = Orderstatususecase(orderRepositoryImpl: orderRepo);
  final placeOrderUsecase = PlaceOrderUsecase(orderRepositoryImpl: orderRepo);

  final getBusinessUsecase = GetbusinessUsecase(repository: businessRepository);
  final searchBusinessesusecase = Searchbusinessesusecase(
    businessrepoimp: businessRepository,
  );
  final getcategoriesusecase = Getcategoriesusecase(repo: menuRepo);
  final getitemsusecase = Getitemsusecase(repo: menuRepo);
  final getprofilesusecase = Getprofilesusecase(repo: profileRepo);
  final updateprofileusecase = Updateprofileusecase(repo: profileRepo);
  final updateProfilePhotoUseCase = Updateprofilephotousecase(
    repo: profileRepo,
  );
  final addFavoriteUseCase = AddFavoriteUsecase(repo: favoriteRepo);
  final removeFavoriteUseCase = RemoveFavoriteUsecase(repo: favoriteRepo);
  final getFavoriteIdUseCase = GetFavoriteIdsUsecase(repo: favoriteRepo);
  final getFavoriteItemUseCase = GetFavoriteItemsUsecase(repo: favoriteRepo);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthBloc>()),
        BlocProvider(
          create: (context) => BusinessBloc(
            getBusinessUsecase: getBusinessUsecase,
            searchbusinessesusecase: searchBusinessesusecase,
          ),
        ),
        BlocProvider(
          create: (context) => PromotionsBloc(promotionsusecase: getpromotions),
        ),
        BlocProvider(
          create: (context) => AddressBloc(
            getAddressesUsecase: getAddressUsecase,
            addAddressUsecase: addAddressUsecase,
            deleteAddressUsecase: deleteAddressUsecase,
            setDefaultAddressUsecase: setDefaultAddressUsecase,
          ),
        ),
        BlocProvider(
          create: (context) => JobBloc(getJobsUsecase: getJobsUsecase),
        ),
        BlocProvider(
          create: (context) => FavoriteBloc(
            addFavoriteUsecase: addFavoriteUseCase,
            removeFavoriteUsecase: removeFavoriteUseCase,
            getFavoriteIdsUsecase: getFavoriteIdUseCase,
            getFavoriteItemsUsecase: getFavoriteItemUseCase,
          ),
        ),
        BlocProvider(
          create: (context) => MenuBloc(
            menuCategoriesusecase: getcategoriesusecase,
            menuItemsusecase: getitemsusecase,
          ),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(
            getProfilesUsecase: getprofilesusecase,
            updateProfileUsecase: updateprofileusecase,
            updateprofilephotousecase: updateProfilePhotoUseCase,
          ),
        ),
        BlocProvider(create: (context) => CartBloc()),
        BlocProvider(
          create: (context) => OrderBloc(
            watchOrderStatusUsecase: orderstatususecase,
            placeOrderUsecase: placeOrderUsecase,
            customerOrdersUsecase: getCostomerOrdersUseCase,
          ),
        ),
      ],
      child: MyApp(hasCompletedOnboarding: hasCompletedOnboarding),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key, 
    this.hasCompletedOnboarding = false, // Default to false
  });

  final bool hasCompletedOnboarding;

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  final Set<String> _checkedOrderIds = {};

  final ReviewRepositoryImpl _reviewRepo = ReviewRepositoryImpl(
    reviewRemoteDatasource: ReviewRemoteDatasource(),
  );

  Future<void> _maybePromptForCompletedOrders(List<dynamic> orders) async {
    for (final order in orders) {
      final orderId = order.id;
      final status = order.orderStatus;

      if (orderId == null) continue;
      if (status != OrderStatus.completed) continue;
      if (_checkedOrderIds.contains(orderId)) continue;

      _checkedOrderIds.add(orderId);

      final alreadyReviewed = await _reviewRepo.hasReviewForOrder(orderId);

      if (alreadyReviewed) continue;

      final navState = MainShell.rootNavigatorKey.currentState;

      if (navState != null) {
        navState.push(
          MaterialPageRoute(
            builder: (_) => RatingPage(order: order),
            fullscreenDialog: true,
          ),
        );
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              context.read<FavoriteBloc>().add(
                LoadFavoritesEvent(userId: state.profile.id),
              );
              context.read<OrderBloc>().add(
                GetCustomerOrdersEvent(customerId: state.profile.id),
              );
            }
          },
        ),
        BlocListener<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is CustomerOrdersFetched) {
              _maybePromptForCompletedOrders(state.orders);
            }
          },
        ),
      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        title: 'Aklatna',
        theme: AppTheme.lightTheme,
      ),
    );
  }
}