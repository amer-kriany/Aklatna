import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton.dart';

class CheckEmailPage extends StatefulWidget {
  const CheckEmailPage({
    super.key,
    required this.email,
    required this.password,
    required this.phone,
  });

  final String email;
  // Held temporarily to re-attempt sign-in once the user confirms via
  // the email link — clicking a link in the browser doesn't establish
  // a session inside the Flutter app itself, so we need to sign in
  // again client-side after they've confirmed.
  final String password;
  final String phone;

  @override
  State<CheckEmailPage> createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
  void _onContinue() {
    context.read<AuthBloc>().add(
          SignInEvent(
            email: widget.email,
            password: widget.password,
            phone: null,
          ),
        );
  }

  void _onResend() {
    context.read<AuthBloc>().add(ResendSignUpOtpEvent(email: widget.email));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إعادة إرسال رابط التأكيد')),
    );
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
                // Email verified! Move forward to Phone Confirmation step
                context.go('/confirm-phone', extra: {
                  'phone': widget.phone,
                });
              }
              if (state is AuthError) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message.contains('confirm')
                            ? 'لم تؤكد بريدك بعد، افتح الرابط في رسالة البريد الإلكتروني أولاً'
                            : state.message,
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 72,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'تحقق من بريدك الإلكتروني',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'أرسلنا رابط تأكيد إلى ${widget.email}\nافتح الرابط لإكمال إنشاء الحساب',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          onPressed: loading ? null : _onContinue,
                          child: loading
                              ? const Skeleton(
                                  width: 20,
                                  height: 20,
                                  isCircle: true,
                                  baseColor: Colors.white24,
                                  highlightColor: Colors.white70,
                                )
                              : Text(
                                  'لقد أكدت بريدي، تابع',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(
                    onPressed: _onResend,
                    child: Text(
                      'لم يصلك البريد؟ إعادة الإرسال',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
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