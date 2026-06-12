import 'package:flutter/material.dart';

import 'package:aklatna/core/constants/app_assets.dart';
import 'package:aklatna/core/constants/app_constants.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_styles.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_text_field.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({this.onSubmit, super.key});

  final VoidCallback? onSubmit;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool get _canSubmit =>
      _usernameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            controller: _usernameController,
            label: AppConstants.authUsernameLabel,
            hint: AppConstants.authUsernameHint,
            iconAsset: AppAssets.person,
            keyboardType: TextInputType.name,
            validator: _requiredValidator,
            onChanged: _handleFieldChanged,
          ),
          const SizedBox(height: AuthStyles.formGap),
          AuthTextField(
            controller: _phoneController,
            label: AppConstants.authPhoneLabel,
            hint: AppConstants.authPhoneHint,
            iconAsset: AppAssets.phone,
            keyboardType: TextInputType.phone,
            validator: _requiredValidator,
            onChanged: _handleFieldChanged,
          ),
          const SizedBox(height: AuthStyles.formGap),
          AuthTextField(
            controller: _emailController,
            label: AppConstants.authOptionalEmailLabel,
            hint: AppConstants.authEmailHint,
            iconAsset: AppAssets.message,
            keyboardType: TextInputType.emailAddress,
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
          const SizedBox(height: AuthStyles.formGap),
          AuthTextField(
            controller: _confirmPasswordController,
            label: AppConstants.authConfirmPasswordLabel,
            hint: AppConstants.authPasswordHint,
            iconAsset: AppAssets.lock,
            isPassword: true,
            validator: _confirmPasswordValidator,
            onChanged: _handleFieldChanged,
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(
            label: AppConstants.authSignUpAction,
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

  String? _confirmPasswordValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) {
      return requiredError;
    }

    return value != _passwordController.text
        ? AppConstants.authPasswordMismatchError
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
