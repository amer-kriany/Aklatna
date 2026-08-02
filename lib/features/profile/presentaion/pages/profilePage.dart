import 'dart:io';
import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
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
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/page_skeletons.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _contactSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'amer.kriany0@gmail.com', // <- put your real support email here
      queryParameters: {'subject': 'مشكلة في تطبيق أكلاتنا'},
    );

    final launched = await launchUrl(emailUri);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد تطبيق بريد إلكتروني مثبت')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (context.read<ProfileBloc>().state is ProfileInitial) {
      context.read<ProfileBloc>().add(GetProfilesEvent());
    }
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      // 1. Fetch current logged-in user directly from Supabase Auth
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('المستخدم غير مسجل الدخول')),
          );
        }
        return;
      }

      final userId = user.id;

      // 2. Pick image
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) return; // Canceled by user

      final file = File(pickedFile.path);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('جاري رفع الصورة...')));

      final fileExt = pickedFile.path.split('.').last;
      final filePath = '$userId/avatar.$fileExt';

      // 3. Upload to Supabase Storage (Exact bucket name match)
      final storage = Supabase.instance.client.storage.from('profile_photo');

      await storage.uploadBinary(
        filePath,
        await file.readAsBytes(),
        fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
      );

      // 4. Generate URL with timestamp cache buster
      final publicUrl = storage.getPublicUrl(filePath);
      final updatedPhotoUrl =
          '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      // 5. Dispatch Event
      if (mounted) {
        context.read<ProfileBloc>().add(
          UpdateProfilePhotoEvent(userId: userId, photo: updatedPhotoUrl),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الصورة الشخصية بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في رفع الصورة: ${e.toString()}')),
        );
      }
    }
  }

  void _showPhotoOptionsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('تغيير الصورة الشخصية', style: AppTextStyles.h4),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('اختيار من المعرض'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadPhoto(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('التقاط صورة بالكاميرا'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadPhoto(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
                  return const ProfileSkeleton();
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
                        photoUrl: profile.photo,
                        userName: profile.userName,
                        email: profile.email,
                        phoneNumber: profile.phoneNumber,
                        onEditPhoto: _showPhotoOptionsSheet,
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
                          ProfileMenuRow(
                            icon: Icons.location_on_outlined,
                            iconColor: AppColors.info,
                            label: 'العناوين',
                            onTap: () => context.push('/addresses'),
                          ),
                          ProfileMenuRow(
                            icon: Icons.favorite_border,
                            iconColor: Colors.pink,
                            label: 'المفضلة',
                            onTap: () => context.push('/favorites'),
                          ),
                          ProfileMenuRow(
                            icon: Icons.support_agent_outlined,
                            iconColor: AppColors.info,
                            label: 'تواصل معنا',
                            onTap: _contactSupport,
                          ),
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
