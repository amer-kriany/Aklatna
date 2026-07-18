import 'package:aklatna/features/favorit/presentation/bloc/favorite_bloc.dart';
import 'package:aklatna/features/home/presentation/widgets/home/BusinessCard.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      context.read<FavoriteBloc>().add(LoadFavoritesEvent(userId: profileState.profile.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('المفضلة', style: AppTextStyles.h4)),
        body: SafeArea(
          child: BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              if (state is FavoriteLoading || state is FavoriteInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is FavoriteError) {
                return Center(child: Text(state.message));
              }
              if (state is! FavoriteLoaded) {
                return const SizedBox.shrink();
              }
              if (state.businesses.isEmpty) {
                return Center(
                  child: Text('لا توجد مطاعم مفضلة بعد', style: AppTextStyles.bodyMedium),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                itemCount: state.businesses.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
               itemBuilder: (context, index) {
  final business = state.businesses[index];
  return BusinessCard(
    businessName: business.nameAr,
    coverUrl: business.coverUrl,
    rating: business.rating,
    ratingCount: business.ratingCount,
    onTap: () => context.push('/business/${business.id}'),
  );
},
              );
            },
          ),
        ),
      ),
    );
  }
}