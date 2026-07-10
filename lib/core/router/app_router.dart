import 'package:aklatna/core/router/MainShell.dart';
import 'package:aklatna/features/home/data/datasources/business_datasrouce.dart';
import 'package:aklatna/features/home/data/repository/businessRepoImp.dart';
import 'package:aklatna/features/home/domain/usecases/getbusiness_usecase.dart';
import 'package:aklatna/features/home/domain/usecases/searchBusinessesUseCase.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/home/presentation/pages/BusinessDetailsPage.dart';
import 'package:aklatna/features/home/presentation/pages/HomaPage.dart';
import 'package:aklatna/features/home/presentation/pages/SearchPage.dart';
import 'package:aklatna/features/menu/data/data_source/menuDataSource.dart';
import 'package:aklatna/features/menu/data/repository/menuRepoImp.dart';
import 'package:aklatna/features/menu/domain/usecases/getCategoriesUseCase.dart';
import 'package:aklatna/features/menu/domain/usecases/getItemsUsecase.dart';
import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:aklatna/features/menu/presentation/pages/FoodDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// TODO(Amer): Fix these imports to match your actual file paths/class names.
// I don't have your real home page import path in this session — swap it in.
// import 'package:aklatna/presentation/home/pages/home_page.dart';

/// Aklatna (أكلتنا) — Root router config.
///
/// If you already have route definitions for auth / other top-level flows,
/// merge this GoRoute list into your existing GoRouter(routes: [...]) — don't
/// just drop this whole file in, since it will likely collide with what you
/// have.
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  navigatorKey: MainShell.rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0 — Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        // Branch 1 — Search
       // Branch 1 — Search
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
        // Branch 2 — Jobs (no Figma design — added outside original scope)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/jobs',
              builder: (context, state) =>
                  const _PlaceholderScreen(label: 'Jobs'),
            ),
          ],
        ),
        // Branch 3 — Orders
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) =>
                  const _PlaceholderScreen(label: 'Orders'),
            ),
          ],
        ),
        // Branch 4 — Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  const _PlaceholderScreen(label: 'Profile'),
            ),
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
    return BlocProvider(
      create: (_) => MenuBloc(
        menuCategoriesusecase: Getcategoriesusecase(repo: menuRepo),
        menuItemsusecase: Getitemsusecase(repo: menuRepo),
      ),
      child: Foodetailspage(itemId: state.pathParameters['id']!),
    );
      },
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
    
  ],
);

/// Temporary stand-in for screens not built yet. Not real UI — just marks
/// where each branch's actual page needs to be wired in.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('$label — TODO: wire real page')));
  }
}
