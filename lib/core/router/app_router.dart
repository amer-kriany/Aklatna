import 'package:aklatna/core/router/MainShell.dart';
import 'package:aklatna/core/router/go_router_refresh_stream.dart';
import 'package:aklatna/features/addOnes/data/datasource/addOnesDataSource.dart';
import 'package:aklatna/features/addOnes/data/repository/addOnesRepoImp.dart';
import 'package:aklatna/features/addOnes/domain/useCases/getAddOnesUseCase.dart';
import 'package:aklatna/features/addOnes/presentation/bloc/add_ones_bloc.dart';
import 'package:aklatna/features/addresses/presentation/pages/AddressesPage.dart';
import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:aklatna/features/auth/presentation/pages/SignInPage.dart';
import 'package:aklatna/features/auth/presentation/pages/checkEmailPage.dart';
import 'package:aklatna/features/auth/presentation/pages/forgotPasswordPage.dart';
import 'package:aklatna/features/auth/presentation/pages/otpVereficationPage.dart';
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
import 'package:aklatna/features/onboarding/presentation/pages/onboardingPage.dart';
import 'package:aklatna/features/orders/presentation/pages/myOrderPage.dart';
import 'package:aklatna/features/profile/presentaion/pages/profilePage.dart';
import 'package:aklatna/features/splash/pages/splashScreen.dart';
import 'package:aklatna/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash', // <-- بداية التطبيق من الـ Splash
  navigatorKey: MainShell.rootNavigatorKey,
  refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
  redirect: (context, state) {
  final authState = sl<AuthBloc>().state;
  final isGoingToAuth = state.matchedLocation == '/signin' ||
      state.matchedLocation == '/signup' ||
      state.matchedLocation == '/check-email' ||   // <-- must be this, not /verify-otp
      state.matchedLocation == '/forgot-password' ||
      state.matchedLocation == '/reset-password';

  if (authState is AuthInitial || authState is AuthLoading) return null;

  final isAuthenticated = authState is AuthAuthenticated;

  if (!isAuthenticated && !isGoingToAuth) return '/signin';
  if (isAuthenticated && isGoingToAuth) return '/home';
  return null;
},
  routes: [
    GoRoute(
      path: '/splash',
      parentNavigatorKey: MainShell.rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      parentNavigatorKey: MainShell.rootNavigatorKey,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/signin',
      parentNavigatorKey: MainShell.rootNavigatorKey,
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: '/signup',
      parentNavigatorKey: MainShell.rootNavigatorKey,
      builder: (context, state) => const SignUpPage(),
    ),
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
        final addonDatasource = Addonesdatasource();
        final addonRepo = AddonRepositoryImpl(datasource: addonDatasource);
        final businessDatasource = BusinessDatasrouce();
        final businessRepo = Businessrepoimp(businessDatasrouce: businessDatasource);

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
            BlocProvider(
              create: (_) => BusinessBloc(
                getBusinessUsecase: GetbusinessUsecase(repository: businessRepo),
                searchbusinessesusecase: Searchbusinessesusecase(businessrepoimp: businessRepo),
              ),
            ),
          ],
          child: Foodetailspage(itemId: state.pathParameters['id']!),
        );
      },
    ),
    GoRoute(
  path: '/check-email',
  parentNavigatorKey: MainShell.rootNavigatorKey,
  builder: (context, state) {
    final args = state.extra as Map<String, dynamic>;
    return CheckEmailPage(
      email: args['email'] as String,
      password: args['password'] as String,
    );
  },
),
    GoRoute(
  path: '/verify-otp',
  parentNavigatorKey: MainShell.rootNavigatorKey,
  builder: (context, state) => OtpVerificationPage(email: state.extra as String),
),
    GoRoute(
      path: '/checkout',
      parentNavigatorKey: MainShell.rootNavigatorKey,
      builder: (context, state) => const CheckoutPage(),
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
      path: '/favorites',
      parentNavigatorKey: MainShell.rootNavigatorKey,
      builder: (context, state) => const FavoritesPage(),
    ),
    GoRoute(
  path: '/forgot-password',
  parentNavigatorKey: MainShell.rootNavigatorKey,
  builder: (context, state) => const ForgotPasswordPage(),
),
    GoRoute(
      path: '/profile',
      parentNavigatorKey: MainShell.rootNavigatorKey,
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);