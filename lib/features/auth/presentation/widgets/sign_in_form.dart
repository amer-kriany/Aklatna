import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';

import 'package:aklatna/core/constants/app_assets.dart';
import 'package:aklatna/core/constants/app_constants.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_styles.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SignInMethod { email, phone }

class SignInForm extends StatefulWidget {
  const SignInForm({this.onForgotPassword, super.key});

  final VoidCallback? onForgotPassword;

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  SignInMethod _method = SignInMethod.phone;

  bool get _canSubmit {
    final identifier = _method == SignInMethod.email
        ? _emailController.text.trim()
        : _phoneController.text.trim();
    return identifier.isNotEmpty && _passwordController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMethod() {
    setState(() {
      _method = _method == SignInMethod.email
          ? SignInMethod.phone
          : SignInMethod.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _method == SignInMethod.email
                ? AuthTextField(
                    key: const ValueKey('email-field'),
                    controller: _emailController,
                    label: AppConstants.authEmailLabel,
                    hint: AppConstants.authEmailHint,
                    iconAsset: AppAssets.message,
                    keyboardType: TextInputType.emailAddress,
                    validator: _requiredValidator,
                    onChanged: _handleFieldChanged,
                  )
                : AuthTextField(
                    key: const ValueKey('phone-field'),
                    controller: _phoneController,
                    label: AppConstants.authPhoneLabel,
                    hint: AppConstants.authPhoneHint,
                    iconAsset: AppAssets.phone,
                    keyboardType: TextInputType.phone,
                    validator: _requiredValidator,
                    onChanged: _handleFieldChanged,
                  ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
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
              TextButton(
                onPressed: _toggleMethod,
                style: TextButton.styleFrom(
                  foregroundColor: AuthStyles.link.color,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _method == SignInMethod.email
                      ? AppConstants.authSignInWithPhone
                      : AppConstants.authSignInWithEmail,
                  style: AuthStyles.link,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocConsumer<AuthBloc, AuthState>(
            listener: (BuildContext context, AuthState state) {
             
              if (state is AuthError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is AuthAuthenticated) {
                // navigate to home page
              }
            },
            builder: (context, state) {
               if(state is AuthLoading){
                return Center(child: CircularProgressIndicator());
              }
              return AuthPrimaryButton(
                label: 
                     Text(AppConstants.authSignInAction),
                onPressed: () {
                  if (_canSubmit) {
                    if (_formKey.currentState?.validate() ?? false) {
                      context.read<AuthBloc>().add(
                        SignInEvent(
                          password: _passwordController.text,
                          email: _emailController.text,
                          phone: _phoneController.text,
                        ),
                      );
                    }
                  }
                },
              );
            },
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
}
