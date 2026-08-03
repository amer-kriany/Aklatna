import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/signIn/AuthHeaderText.dart';
import '../widgets/signIn/AuthLogo.dart';
import '../widgets/signIn/AuthPrimaryButton.dart';
import '../widgets/signIn/AuthTextField.dart';

class ConfirmPhonePage extends StatefulWidget {
  const ConfirmPhonePage({
    super.key,
    required this.initialPhone,
  });

  final String initialPhone;

  @override
  State<ConfirmPhonePage> createState() => _ConfirmPhonePageState();
}

class _ConfirmPhonePageState extends State<ConfirmPhonePage> {
  final _confirmPhoneController = TextEditingController();

  @override
  void dispose() {
    _confirmPhoneController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final confirmedPhone = _confirmPhoneController.text.trim();

    if (confirmedPhone.isEmpty) {
      _showError('الرجاء إدخال رقم الهاتف للتأكيد');
      return;
    }

    // Compare with the phone used during SignUp
    if (confirmedPhone != widget.initialPhone.trim()) {
      _showError('رقم الهاتف غير متطابق مع الرقم المدخل سابقاً!');
      return;
    }

    // Success! Everything matches and Supabase account is active.
    context.go('/home');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AuthLogo()),
                const SizedBox(height: AppSpacing.xl),

                const AuthHeaderText(
                  title: 'تأكيد رقم الهاتف 📱',
                  subtitle: 'أعد إدخال رقم هاتفك لتأكيد صحته والتأكد من إمكانية التواصل معك عند التوصيل',
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Single Field: Re-enter Phone Number
                AuthTextField(
                  label: 'تأكيد رقم الهاتف',
                  hint: 'أدخل رقم الهاتف مرة أخرى',
                  controller: _confirmPhoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.xxl),

                AuthPrimaryButton(
                  label: 'تأكيد ومتابعة إلى الرئيسية',
                  onPressed: _onConfirm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}