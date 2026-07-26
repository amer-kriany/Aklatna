import 'dart:io';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthPrimaryButton.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthTextField.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    final profile = state is ProfileLoaded ? state.profile : null;
    _usernameController = TextEditingController(text: profile?.userName ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 80);
      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final fileExt = pickedFile.path.split('.').last;
      final filePath = '${user.id}/avatar.$fileExt';
      final storage = Supabase.instance.client.storage.from('profile_photo');

      await storage.uploadBinary(
        filePath,
        await file.readAsBytes(),
        fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
      );

      final publicUrl = storage.getPublicUrl(filePath);
      final updatedPhotoUrl = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      if (mounted) {
        context.read<ProfileBloc>().add(
          UpdateProfilePhotoEvent(userId: user.id, photo: updatedPhotoUrl),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('تغيير الصورة الشخصية', style: AppTextStyles.h4),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                  title: const Text('اختيار من المعرض'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadPhoto(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
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

  void _onSave() {
    final state = context.read<ProfileBloc>().state;
    if (state is! ProfileLoaded) return;

    context.read<ProfileBloc>().add(
      UpdateProfileEvent(
        userId: state.profile.id,
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('المعلومات الشخصية', style: AppTextStyles.h4)),
        body: SafeArea(
          child: BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileUpdated) {
                Navigator.pop(context);
                context.read<ProfileBloc>().add(GetProfilesEvent());
              }
              if (state is ProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      final photoUrl = state is ProfileLoaded ? state.profile.photo : null;
                      final hasValidPhoto = photoUrl != null &&
                          (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'));

                      return Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(48),
                              child: SizedBox(
                                width: 96,
                                height: 96,
                                child: hasValidPhoto
                                    ? Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          color: AppColors.surface,
                                          alignment: Alignment.center,
                                          child: const Icon(Icons.person, size: AppSizes.iconXl, color: AppColors.textSecondary),
                                        ),
                                      )
                                    : Container(
                                        color: AppColors.surface,
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.person, size: AppSizes.iconXl, color: AppColors.textSecondary),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: InkWell(
                                onTap: _showPhotoOptionsSheet,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.background, width: 2),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.edit, color: AppColors.textOnPrimary, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AuthTextField(label: 'الاسم', hint: 'أدخل اسمك', controller: _usernameController),
                  const SizedBox(height: AppSpacing.lg),
                  AuthTextField(label: 'نبذة عني', hint: 'اكتب نبذة قصيرة', controller: _bioController),
                  const SizedBox(height: AppSpacing.xl),
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      return AuthPrimaryButton(
                        label: 'حفظ',
                        onPressed: state is ProfileLoading ? null : _onSave,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}