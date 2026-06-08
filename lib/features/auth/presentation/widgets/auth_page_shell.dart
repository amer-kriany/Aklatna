import 'package:flutter/material.dart';

import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_styles.dart';

class AuthPageShell extends StatelessWidget {
  const AuthPageShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AuthStyles.horizontalPadding,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
