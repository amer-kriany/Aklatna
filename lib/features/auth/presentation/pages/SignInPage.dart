import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthDividerOr.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthFooterLink.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthGoogleButton.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthHeaderText.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthLogo.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthPrimaryButton.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';


class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    if (phone.isEmpty || password.isEmpty) return; // TODO(Amer): real field validation/error messages

    context.read<AuthBloc>().add(SignInEvent(phone: phone, password: password));
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
                    title: 'تسجيل الدخول إلى حسابك',
                    subtitle: 'أدخل رقم هاتفك وكلمة المرور لتسجيل الدخول',
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AuthTextField(
                    label: 'رقم الهاتف',
                    hint: 'أدخل رقم هاتفك',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
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
                        label: 'تسجيل الدخول',
                        onPressed: state is AuthLoading ? null : _onLogin,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  const AuthDividerOr(),
                  const SizedBox(height: AppSpacing.xl),

                  AuthGoogleButton(
                    onPressed: () {
                      // TODO(Amer): no Google auth usecase exists yet.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('قريباً')),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  AuthFooterLink(
                    text: 'ليس لديك حساب؟',
                    actionText: 'إنشاء حساب',
                    onTap: () => context.push('/signup'),
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