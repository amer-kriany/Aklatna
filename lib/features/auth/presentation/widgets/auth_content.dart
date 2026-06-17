import 'package:flutter/material.dart';

import 'package:aklatna/features/auth/presentation/widgets/auth_card.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_header.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_legal_text.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_tabs.dart';
import 'package:aklatna/features/auth/presentation/widgets/sign_in_form.dart';
import 'package:aklatna/features/auth/presentation/widgets/sign_up_form.dart';

class AuthContent extends StatelessWidget {
  const AuthContent({
    required this.activeTab,
    required this.onTabChanged,
    this.onForgotPassword,
    this.onSignIn,
    this.onSignUp,
    super.key,
  });

  final AuthTab activeTab;
  final ValueChanged<AuthTab> onTabChanged;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignIn;
  final VoidCallback? onSignUp;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      children: [
        const AuthHeader(),
        const SizedBox(height: 24),
        AuthTabs(activeTab: activeTab, onChanged: onTabChanged),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: activeTab == AuthTab.signIn
              ? SignInForm(
                  key: const ValueKey('sign-in-form'),
                  onForgotPassword: onForgotPassword,
                )
              : SignUpForm(
                  key: const ValueKey('sign-up-form'),
                  onSubmit: onSignUp,
                ),
        ),
        const SizedBox(height: 40),
        const AuthLegalText(),
      ],
    );
  }
}
