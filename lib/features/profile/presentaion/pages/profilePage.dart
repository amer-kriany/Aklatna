import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:aklatna/features/profile/presentaion/pages/PersonalInfoPage.dart';
import 'package:aklatna/features/profile/presentaion/widgets/ProfileMenuCard.dart';
import 'package:aklatna/features/profile/presentaion/widgets/ProfileMenuRow.dart';
import 'package:aklatna/features/profile/presentaion/widgets/profileHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    if (context.read<ProfileBloc>().state is ProfileInitial) {
      context.read<ProfileBloc>().add(GetProfilesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('حسابي', style: AppTextStyles.h4),
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                context.go('/signin');
              }
            },
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading || state is ProfileInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ProfileError) {
                  return Center(child: Text(state.message));
                }
                if (state is! ProfileLoaded) {
                  return const SizedBox.shrink();
                }

                final profile = state.profile;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.xl),

                      ProfileHeader(
                        photoUrl: profile.profilePhoto,
                        userName: profile.userName,
                        email: profile.email,
                        phoneNumber: profile.phoneNumber,
                        onEditPhoto: () {
                          // TODO(Amer): image picker + upload to Supabase Storage.
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      ProfileMenuCard(
                        children: [
                          ProfileMenuRow(
                            icon: Icons.person_outline,
                            iconColor: AppColors.primary,
                            label: 'المعلومات الشخصية',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PersonalInfoPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ProfileMenuRow(
                        icon: Icons.favorite_border,
                        iconColor: Colors.pink,
                        label: 'المفضلة',
                        onTap: () => context.push('/favorites'),
                      ),

                      ProfileMenuCard(
                        children: [
                          ProfileMenuRow(
                            icon: Icons.logout,
                            iconColor: AppColors.error,
                            label: 'تسجيل الخروج',
                            onTap: () =>
                                context.read<AuthBloc>().add(SignOutEvent()),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
