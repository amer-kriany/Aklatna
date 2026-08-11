import 'package:aklatna/core/router/app_router.dart';
import 'package:aklatna/core/router/MainShell.dart';
import 'package:aklatna/core/theme/app_theme.dart';
import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:aklatna/features/review/data/datasource/reviewRemoteDatasource.dart';
import 'package:aklatna/features/review/data/repository/reviewRepoImp.dart';
import 'package:aklatna/features/review/presentaion/pages/ratingPage.dart';
import 'package:aklatna/features/favorit/presentation/bloc/favorite_bloc.dart';
import 'package:aklatna/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.hasCompletedOnboarding = false});

  final bool hasCompletedOnboarding;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ReviewRepositoryImpl _reviewRepo = ReviewRepositoryImpl(
    reviewRemoteDatasource: ReviewRemoteDatasource(),
  );

  @override
  void initState() {
    super.initState();
    final authState = sl<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      sl<ProfileBloc>().add(GetProfilesEvent());
    }
  }

  Future<void> _maybePromptForCompletedOrder(OrderEntity order) async {
    final orderId = order.id;
    if (orderId == null) return;

    final alreadyReviewed = await _reviewRepo.hasReviewForOrder(orderId);
    if (alreadyReviewed) return;

    final navState = MainShell.rootNavigatorKey.currentState;
    if (navState != null) {
      navState.push(
        MaterialPageRoute(
          builder: (_) => RatingPage(order: order),
          fullscreenDialog: true,
        ),
      );
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
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.read<ProfileBloc>().add(GetProfilesEvent());
            }
          },
        ),
        BlocListener<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderJustCompleted) {
              _maybePromptForCompletedOrder(state.order);
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