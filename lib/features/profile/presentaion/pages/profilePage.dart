import 'dart:io';

import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';

import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:aklatna/features/profile/presentaion/pages/PersonalInfoPage.dart';
import 'package:aklatna/features/profile/presentaion/widgets/ProfileMenuCard.dart';
import 'package:aklatna/features/profile/presentaion/widgets/ProfileMenuRow.dart';

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

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.025), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    if (context.read<ProfileBloc>().state is ProfileInitial) {
      context.read<ProfileBloc>().add(GetProfilesEvent());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // SUPPORT
  // ============================================================

  Future<void> _contactSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'amer.kriany0@gmail.com',
      queryParameters: {'subject': 'مشكلة في تطبيق أكلاتنا'},
    );

    final launched = await launchUrl(emailUri);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد تطبيق بريد إلكتروني مثبت')),
      );
    }
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  void _showSignOutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'تسجيل الخروج',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'هل أنت متأكد من أنك تريد تسجيل الخروج من حسابك؟',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 26),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            side: BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: Text(
                            'إلغاء',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();

                            context.read<AuthBloc>().add(SignOutEvent());
                          },
                          child: Text(
                            'تسجيل الخروج',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PHOTO
  // ============================================================

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('المستخدم غير مسجل الدخول')),
          );
        }

        return;
      }

      final picker = ImagePicker();

      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        return;
      }

      final file = File(pickedFile.path);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('جاري رفع الصورة...')));

      final fileExt = pickedFile.path.split('.').last;

      final filePath = '${user.id}/avatar.$fileExt';

      final storage = Supabase.instance.client.storage.from('profile_photo');

      await storage.uploadBinary(
        filePath,
        await file.readAsBytes(),
        fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
      );

      final publicUrl = storage.getPublicUrl(filePath);

      final updatedPhotoUrl =
          '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      if (!mounted) return;

      context.read<ProfileBloc>().add(
        UpdateProfilePhotoEvent(userId: user.id, photo: updatedPhotoUrl),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الصورة الشخصية بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في رفع الصورة: ${e.toString()}')),
      );
    }
  }

  // ============================================================
  // PHOTO OPTIONS
  // ============================================================

  void _showPhotoOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      'تغيير الصورة الشخصية',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'اختر الطريقة التي تريد استخدامها',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: _PhotoOption(
                            icon: Icons.photo_library_outlined,
                            title: 'المعرض',
                            onTap: () {
                              Navigator.pop(sheetContext);

                              _pickAndUploadPhoto(ImageSource.gallery);
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _PhotoOption(
                            icon: Icons.camera_alt_outlined,
                            title: 'الكاميرا',
                            onTap: () {
                              Navigator.pop(sheetContext);

                              _pickAndUploadPhoto(ImageSource.camera);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // MENU SECTION
  // ============================================================

  Widget _buildMenuSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 10),

        ProfileMenuCard(children: children),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,

        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,

          centerTitle: true,

          title: Text(
            'حسابي',
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
          ),
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
                  return _buildErrorState(state.message);
                }

                if (state is! ProfileLoaded) {
                  return const SizedBox.shrink();
                }

                final profile = state.profile;

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        context.read<ProfileBloc>().add(GetProfilesEvent());

                        await Future.delayed(const Duration(milliseconds: 500));
                      },

                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),

                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          32,
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ==================================================
                            // PROFILE HERO
                            // ==================================================
                            _buildProfileHero(profile),

                            const SizedBox(height: 28),

                            // ==================================================
                            // ACCOUNT
                            // ==================================================
                            _buildMenuSection(
                              title: 'الحساب',
                              children: [
                                ProfileMenuRow(
                                  icon: Icons.person_outline_rounded,
                                  iconColor: AppColors.primary,
                                  label: 'المعلومات الشخصية',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const PersonalInfoPage(),
                                      ),
                                    );
                                  },
                                ),

                                ProfileMenuRow(
                                  icon: Icons.location_on_outlined,
                                  iconColor: AppColors.info,
                                  label: 'عناويني',
                                  onTap: () {
                                    context.push('/addresses');
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ==================================================
                            // YOUR ACTIVITY
                            // ==================================================
                            _buildMenuSection(
                              title: 'نشاطك',
                              children: [
                                ProfileMenuRow(
                                  icon: Icons.favorite_border_rounded,
                                  iconColor: Colors.pink,
                                  label: 'المفضلة',
                                  onTap: () {
                                    context.push('/favorites');
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ==================================================
                            // SUPPORT
                            // ==================================================
                            _buildMenuSection(
                              title: 'المساعدة',
                              children: [
                                ProfileMenuRow(
                                  icon: Icons.support_agent_outlined,
                                  iconColor: AppColors.info,
                                  label: 'تواصل معنا',
                                  onTap: _contactSupport,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ==================================================
                            // SIGN OUT
                            // ==================================================
                            _buildLogoutButton(context),

                            const SizedBox(height: 28),

                            // ==================================================
                            // BRAND FOOTER
                            // ==================================================
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'أكلاتنا',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'طلبك، أسهل وأسرع 🍽️',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HERO
  // ============================================================

  Widget _buildProfileHero(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: _showPhotoOptionsSheet,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.18),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child:
                        profile.photo != null &&
                            profile.photo.toString().isNotEmpty
                        ? Image.network(
                            profile.photo,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _avatarFallback();
                            },
                          )
                        : _avatarFallback(),
                  ),
                ),

                Positioned(
                  bottom: -2,
                  left: -2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // User information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                if (profile.phoneNumber != null &&
                    profile.phoneNumber.toString().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    profile.phoneNumber.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Edit
          Material(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PersonalInfoPage()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AVATAR FALLBACK
  // ============================================================

  Widget _avatarFallback() {
    return Container(
      color: AppColors.primary.withOpacity(0.08),
      child: const Icon(
        Icons.person_outline_rounded,
        color: AppColors.primary,
        size: 38,
      ),
    );
  }

  // ============================================================
  // LOGOUT BUTTON
  // ============================================================

  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: AppColors.error.withOpacity(0.06),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          _showSignOutConfirmationDialog(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 21,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  'تسجيل الخروج',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const Icon(Icons.chevron_left_rounded, color: AppColors.error),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.error,
                size: 34,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'تعذر تحميل الحساب',
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                context.read<ProfileBloc>().add(GetProfilesEvent());
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.buttonMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// PHOTO OPTION
// ================================================================

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _PhotoOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
