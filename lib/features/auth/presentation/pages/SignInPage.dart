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
    if (phone.isEmpty || password.isEmpty) return;

    context.read<AuthBloc>().add(SignInEvent(phone: phone, password: password));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
  if (state is AuthAuthenticated) {
    context.go('/home');
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
                                title: 'مرحباً بك مجدداً 👋',
                                subtitle:
                                    'أدخل رقم هاتفك وكلمة المرور لتسجيل الدخول',
                              ),
                              const SizedBox(height: AppSpacing.xxl),

                              // Phone Input Field
                              AuthTextField(
                                label: 'رقم الهاتف',
                                hint: 'أدخل رقم هاتفك',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Password Input Field
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
                              Align(
  alignment: Alignment.centerLeft,
  child: TextButton(
    onPressed: () => context.push('/forgot-password'),
    child: Text('نسيت كلمة المرور؟', style: TextStyle(color: AppColors.primary)),
  ),
),
                              const SizedBox(height: AppSpacing.xxl),

                              // Login Action Button
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return AuthPrimaryButton(
                                    label: 'تسجيل الدخول',
                                    onPressed: state is AuthLoading
                                        ? null
                                        : _onLogin,
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
                                  text: 'ليس لديك حساب؟',
                                  actionText: 'إنشاء حساب جديد',
                                  onTap: () => context.push('/signup'),
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
