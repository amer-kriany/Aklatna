import 'package:flutter/material.dart';

import 'package:aklatna/core/constants/app_assets.dart';
import 'package:aklatna/core/constants/app_constants.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_styles.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_text_field.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({this.onForgotPassword, this.onSubmit, super.key});

  final VoidCallback? onForgotPassword;
  final VoidCallback? onSubmit;

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool get _canSubmit =>
      _emailOrPhoneController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _emailOrPhoneController,
            label: AppConstants.authEmailOrPhoneLabel,
            hint: AppConstants.authEmailOrPhoneHint,
            iconAsset: AppAssets.person,
            keyboardType: TextInputType.emailAddress,
            validator: _requiredValidator,
            onChanged: _handleFieldChanged,
          ),
          const SizedBox(height: AuthStyles.formGap),
          AuthTextField(
            controller: _passwordController,
            label: AppConstants.authPasswordLabel,
            hint: AppConstants.authPasswordHint,
            iconAsset: AppAssets.lock,
            isPassword: true,
            validator: _requiredValidator,
            onChanged: _handleFieldChanged,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              style: TextButton.styleFrom(
                foregroundColor: AuthStyles.link.color,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                AppConstants.authForgotPassword,
                style: AuthStyles.link,
              ),
            ),
          ),
          const SizedBox(height: 12),
          AuthPrimaryButton(
            label: AppConstants.authSignInAction,
            onPressed: _canSubmit ? _submit : null,
          ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) {
    return value == null || value.trim().isEmpty
        ? AppConstants.authRequiredFieldError
        : null;
  }

  void _handleFieldChanged(String value) {
    setState(() {});
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit?.call();
    }
  }
}
