import 'package:flutter/material.dart';

import 'package:aklatna/core/constants/app_assets.dart';
import 'package:aklatna/core/constants/app_constants.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_styles.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.primaryDark,
            shape: BoxShape.circle,
          ),
          child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
        ),
        const SizedBox(height: 12),
        const Text(
          AppConstants.appName,
          style: AuthStyles.logoTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          AppConstants.authWelcomeMessage,
          style: AuthStyles.subtitle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
