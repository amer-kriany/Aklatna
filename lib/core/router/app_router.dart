import 'package:aklatna/core/router/MainShell.dart';
import 'package:aklatna/core/router/go_router_refresh_stream.dart';
import 'package:aklatna/features/addOnes/data/datasource/addOnesDataSource.dart';
import 'package:aklatna/features/addOnes/data/repository/addOnesRepoImp.dart';
import 'package:aklatna/features/addOnes/domain/useCases/getAddOnesUseCase.dart';
import 'package:aklatna/features/addOnes/presentation/bloc/add_ones_bloc.dart';
import 'package:aklatna/features/addresses/presentation/pages/AddressesPage.dart';
import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:aklatna/features/auth/presentation/pages/SignInPage.dart';
import 'package:aklatna/features/auth/presentation/pages/signUpPage.dart';
import 'package:aklatna/features/cart/presentation/pages/CheckoutPage.dart';
import 'package:aklatna/features/cart/presentation/pages/cart_page.dart';
import 'package:aklatna/features/cart/presentation/pages/orderPlacedPage.dart';
import 'package:aklatna/features/favorit/presentation/pages/favoritPage.dart';
import 'package:aklatna/features/home/data/datasources/business_datasrouce.dart';
import 'package:aklatna/features/home/data/repository/businessRepoImp.dart';
import 'package:aklatna/features/home/domain/usecases/getbusiness_usecase.dart';
import 'package:aklatna/features/home/domain/usecases/searchBusinessesUseCase.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/home/presentation/pages/BusinessDetailsPage.dart';
import 'package:aklatna/features/home/presentation/pages/HomaPage.dart';
import 'package:aklatna/features/home/presentation/pages/SearchPage.dart';
import 'package:aklatna/features/job_listings/presentation/pages/jobs_page.dart';
import 'package:aklatna/features/menu/data/data_source/menuDataSource.dart';
import 'package:aklatna/features/menu/data/repository/menuRepoImp.dart';
import 'package:aklatna/features/menu/domain/usecases/getCategoriesUseCase.dart';
import 'package:aklatna/features/menu/domain/usecases/getItemsUsecase.dart';
import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:aklatna/features/menu/presentation/pages/FoodDetailsPage.dart';
import 'package:aklatna/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:aklatna/features/orders/data/repositories/order_repository_impl.dart';
import 'package:aklatna/features/orders/domain/usecases/get_customer_orders_usecase.dart';
import 'package:aklatna/features/orders/domain/usecases/orderStatusUseCase.dart';
import 'package:aklatna/features/orders/domain/usecases/place_order_usecase.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aklatna/features/orders/presentation/pages/myOrderPage.dart';
import 'package:aklatna/features/profile/presentaion/pages/profilePage.dart';
import 'package:aklatna/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  navigatorKey: MainShell.rootNavigatorKey,
  refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
  redirect: (context, state) {
    final authState = sl<AuthBloc>().state;
    final isGoingToAuth = state.matchedLocation == '/signin' || state.matchedLocation == '/signup';

    // Still checking session on cold start — don't redirect yet, avoids
    // bouncing a genuinely logged-in user to /signin for a frame.
    if (authState is AuthInitial || authState is AuthLoading) return null;

    final isAuthenticated = authState is AuthAuthenticated;

    if (!isAuthenticated && !isGoingToAuth) return '/signin';
    if (isAuthenticated && isGoingToAuth) return '/home';
    return null;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) {
                final businessDatasource = BusinessDatasrouce();
                final businessRepo = Businessrepoimp(businessDatasrouce: businessDatasource);
                return BlocProvider(
                  create: (_) => BusinessBloc(
                    getBusinessUsecase: GetbusinessUsecase(repository: businessRepo),
                    searchbusinessesusecase: Searchbusinessesusecase(businessrepoimp: businessRepo),
                  ),
                  child: const SearchPage(),
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/cart', builder: (context, state) => CartPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/orders', builder: (context, state) => const MyOrdersPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/jobs', builder: (context, state) => const JobsPage()),
          ],
        ),
      ],
    ),
    GoRoute(
  path: '/food/:id',
  parentNavigatorKey: MainShell.rootNavigatorKey,
  builder: (context, state) {
    final menuDatasource = Menudatasource();
    final menuRepo = Menurepoimp(menudatasource: menuDatasource);
    final addonDatasource = Addonesdatasource(); // adjust to your real class name
    final addonRepo = AddonRepositoryImpl(datasource: addonDatasource); // adjust to your real class name

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MenuBloc(
            menuCategoriesusecase: Getcategoriesusecase(repo: menuRepo),
            menuItemsusecase: Getitemsusecase(repo: menuRepo),
          ),
        ),
        BlocProvider(
          create: (_) => AddonBloc(getAddonsUsecase: GetAddonsUsecase(repo: addonRepo)),
        ),
      ],
      child: Foodetailspage(itemId: state.pathParameters['id']!),
    );
  },
),
    GoRoute(
      path: '/checkout',
      parentNavigatorKey: MainShell.rootNavigatorKey,
      builder: (context, state) {
        final orderRepo = OrderRepositoryImpl(orderRemoteDatasource: OrderRemoteDatasource());
        return BlocProvider(
          create: (_) => OrderBloc(
         placeOrderUsecase:   PlaceOrderUsecase( orderRepositoryImpl: orderRepo),
         customerOrdersUsecase:   GetCustomerOrdersUseCase( orderRepositoryImpl: orderRepo),
            watchOrderStatusUsecase: Orderstatususecase( orderRepositoryImpl: orderRepo), 
          ),
          child: const CheckoutPage(),
        );
      },
    ),
    GoRoute(
  path: '/addresses',
  parentNavigatorKey: MainShell.rootNavigatorKey,
  builder: (context, state) => const AddressesPage(),
),
    GoRoute(
      path: '/order-placed',
      parentNavigatorKey: MainShell.rootNavigatorKey,
      builder: (context, state) => const OrderPlacedPage(),
    ),
    GoRoute(
      path: '/business/:id',
      parentNavigatorKey: MainShell.rootNavigatorKey,
      builder: (context, state) {
        final businessDatasource = BusinessDatasrouce();
        final businessRepo = Businessrepoimp(businessDatasrouce: businessDatasource);
        final menuDatasource = Menudatasource();
        final menuRepo = Menurepoimp(menudatasource: menuDatasource);
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => BusinessBloc(
                getBusinessUsecase: GetbusinessUsecase(repository: businessRepo),
                searchbusinessesusecase: Searchbusinessesusecase(businessrepoimp: businessRepo),
              ),
            ),
            BlocProvider(
              create: (_) => MenuBloc(
                menuCategoriesusecase: Getcategoriesusecase(repo: menuRepo),
                menuItemsusecase: Getitemsusecase(repo: menuRepo),
              ),
            ),
          ],
          child: BusinessDetailsPage(businessId: state.pathParameters['id']!),
        );
      },
    ),
    GoRoute(
      path: '/signin',
      parentNavigatorKey: MainShell.rootNavigatorKey,
      builder: (context, state) => const SignInPage(),
    ),
    
    GoRoute(
  path: '/favorites',
  parentNavigatorKey: MainShell.rootNavigatorKey,
  builder: (context, state) => const FavoritesPage(),
),
    GoRoute(
      path: '/signup',
      parentNavigatorKey: MainShell.rootNavigatorKey,
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
  path: '/profile',
  parentNavigatorKey: MainShell.rootNavigatorKey,
  builder: (context, state) => const ProfilePage(),
),
  ],
);

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('$label — TODO: wire real page')));
  }
}