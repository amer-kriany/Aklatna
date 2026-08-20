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
import '../../../../core/theme/app_colors.dart';

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

    if (username.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      return;
    }

    context.read<AuthBloc>().add(
      SignUpEvent(
        email: email,
        phone: phone,
        password: password,
        username: username,
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
          child:BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthSignUpOtpSent) {
      context.push('/check-email', extra: {
        'email': state.email,
        'password': _passwordController.text,
        'phone': _phoneController.text.trim(), // <--- Pass the phone forward!
      });
    }
    if (state is AuthError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.redAccent,
          ),
        );
    }
  },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Form Content Grouped Together
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: AppSpacing.lg),

                              // Logo
                              const Center(child: AuthLogo()),
                              const SizedBox(height: AppSpacing.xl),

                              // Header Text
                              const AuthHeaderText(
                                title: 'إنشاء حساب جديد ✨',
                                subtitle: 'أدخل بياناتك لإنشاء حسابك في أكلاتنا',
                              ),
                              const SizedBox(height: AppSpacing.xxl),

                              // Name Input
                              AuthTextField(
                                label: 'الاسم',
                                hint: 'أدخل اسمك الكامل',
                                controller: _usernameController,
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Phone Input
                              AuthTextField(
                                label: 'رقم الهاتف',
                                hint: 'أدخل رقم هاتفك',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Email Input
                              AuthTextField(
                                label: 'البريد الإلكتروني',
                                hint: 'أدخل بريدك الإلكتروني',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Password Input
                              AuthTextField(
                                label: 'كلمة المرور',
                                hint: 'أدخل كلمة المرور',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),

                              // Sign Up Action Button
                             BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    return AuthPrimaryButton(
      label: 'إنشاء حساب', // أو 'تسجيل الدخول' بالـ sign in
      isLoading: state is AuthLoading,
      onPressed: state is AuthLoading ? null : _onSignUp,
    );
  },
),
                            ],
                          ),

                          // Bottom Footer Grouped
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xl),
                            child: Column(
                              children: [
                              AuthFooterLink(
  text: 'لديك حساب بالفعل؟',
  actionText: 'تسجيل الدخول',
  onTap: () => context.go('/signin'),
),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                            ),
                          ),
                        ],
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
}