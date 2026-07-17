import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthFooterLink.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthHeaderText.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthLogo.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthPrimaryButton.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      return; // TODO(Amer): real field validation/error messages
    }

    context.read<AuthBloc>().add(
      SignUpEvent(email: email, phone: phone, password: password, username: username),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                context.go('/home');
              }
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AuthLogo(),
                  const SizedBox(height: AppSpacing.xxl),

                  const AuthHeaderText(
                    title: 'إنشاء حساب جديد',
                    subtitle: 'أدخل بياناتك لإنشاء حسابك',
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AuthTextField(
                    label: 'الاسم',
                    hint: 'أدخل اسمك',
                    controller: _usernameController,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AuthTextField(
                    label: 'رقم الهاتف',
                    hint: 'أدخل رقم هاتفك',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AuthTextField(
                    label: 'البريد الإلكتروني',
                    hint: 'أدخل بريدك الإلكتروني',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AuthTextField(
                    label: 'كلمة المرور',
                    hint: 'أدخل كلمة المرور',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AuthPrimaryButton(
                        label: 'إنشاء حساب',
                        onPressed: state is AuthLoading ? null : _onSignUp,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  AuthFooterLink(
                    text: 'لديك حساب بالفعل؟',
                    actionText: 'تسجيل الدخول',
                    onTap: () => context.pop(),
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