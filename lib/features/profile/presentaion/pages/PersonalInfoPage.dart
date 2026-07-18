import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthPrimaryButton.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthTextField.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';


class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    final profile = state is ProfileLoaded ? state.profile : null;
    _usernameController = TextEditingController(text: profile?.userName ?? '');
    _addressController = TextEditingController(text: profile?.address ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSave() {
    final state = context.read<ProfileBloc>().state;
    if (state is! ProfileLoaded) return;

    context.read<ProfileBloc>().add(
      UpdateProfileEvent(
        userId: state.profile.id,
        username: _usernameController.text.trim(),
        address: _addressController.text.trim(),
        photo: state.profile.profilePhoto, // unchanged here — photo edited separately
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
                context.read<ProfileBloc>().add(GetProfilesEvent()); // refresh
              }
              if (state is ProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthTextField(label: 'الاسم', hint: 'أدخل اسمك', controller: _usernameController),
                  const SizedBox(height: AppSpacing.lg),
                  AuthTextField(label: 'العنوان', hint: 'أدخل عنوانك', controller: _addressController),
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