import 'package:aklatna/app.dart';
import 'package:aklatna/core/services/onboarding_service.dart';
import 'package:aklatna/features/addresses/presentation/bloc/address_bloc.dart';
import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/favorit/presentation/bloc/favorite_bloc.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/job_listings/presentation/bloc/job_bloc.dart';
import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:aklatna/features/promotions/presentaion/bloc/promotions_bloc.dart';
import 'package:aklatna/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  setupInjection();

  final bool hasCompletedOnboarding = await OnboardingService.isCompleted();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthBloc>()),
        BlocProvider.value(value: sl<ProfileBloc>()),
        BlocProvider(create: (_) => sl<BusinessBloc>()),
        BlocProvider(create: (_) => sl<PromotionsBloc>()),
        BlocProvider(create: (_) => sl<AddressBloc>()),
        BlocProvider(create: (_) => sl<JobBloc>()),
        BlocProvider(create: (_) => sl<FavoriteBloc>()),
        BlocProvider(create: (_) => sl<MenuBloc>()),
        BlocProvider(create: (_) => sl<CartBloc>()),
        BlocProvider(create: (_) => sl<OrderBloc>()),
      ],
      child: MyApp(hasCompletedOnboarding: hasCompletedOnboarding),
    ),
  );
}