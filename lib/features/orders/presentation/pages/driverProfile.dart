import 'dart:io';
import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
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

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  // ============================================================
  // CONTACT SUPPORT
  // ============================================================

  Future<void> _contactSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'amer.kriany0@gmail.com',
      queryParameters: {'subject': 'مشكلة في تطبيق أكلاتنا - سائق'},
    );

    final launched = await launchUrl(emailUri);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد تطبيق بريد إلكتروني مثبت')),
      );
    }
  }

  // ============================================================
  // EDIT NAME
  // ============================================================

  void _showEditNameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تعديل الاسم'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'الاسم'),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newName = controller.text.trim();
                  if (newName.isEmpty) return;

                  final userId = Supabase.instance.client.auth.currentUser!.id;

                  context.read<ProfileBloc>().add(
                    UpdateProfileEvent(
                      userId: userId,
                      username: newName,
                      bio: null,
                      phone: null,
                    ),
                  );

                  // profiles.username and drivers.name are two separate
                  // columns -- the event above only touches profiles.
                  // Keep drivers.name in sync since this page is
                  // driver-only and other drivers/restaurants may read
                  // that column directly (e.g. order display).
                  try {
                    await Supabase.instance.client
                        .from('drivers')
                        .update({'name': newName})
                        .eq('id', userId);
                  } catch (_) {
                    // profiles update already dispatched; don't block
                    // on this secondary sync failing.
                  }

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // PHOTO UPLOAD (same pipeline as customer ProfilePage)
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

      final userId = user.id;

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('جاري رفع الصورة...')));

      final fileExt = pickedFile.path.split('.').last;
      final filePath = '$userId/avatar.$fileExt';

      final storage = Supabase.instance.client.storage.from('profile_photo');

      await storage.uploadBinary(
        filePath,
        await file.readAsBytes(),
        fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
      );

      final publicUrl = storage.getPublicUrl(filePath);
      final updatedPhotoUrl =
          '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: AppColors.background,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تسجيل الخروج',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'هل أنت تأكد من أنك تريد تسجيل الخروج؟',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(
                            'إلغاء',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            context.read<AuthBloc>().add(SignOutEvent());
                          },
                          child: Text(
                            'تأكيد الخروج',
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
                            icon: Icons.edit_outlined,
                            iconColor: AppColors.primary,
                            label: 'تعديل الاسم',
                            onTap: () => _showEditNameDialog(profile.userName),
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
                                _showSignOutConfirmationDialog(context),
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
