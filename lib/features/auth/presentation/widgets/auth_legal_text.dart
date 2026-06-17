import 'package:flutter/material.dart';

import 'package:aklatna/core/constants/app_constants.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_styles.dart';

class AuthLegalText extends StatelessWidget {
  const AuthLegalText({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 17),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Text.rich(
        TextSpan(
          style: AuthStyles.legal,
          children: [
            const TextSpan(text: AppConstants.authTermsPrefix),
            TextSpan(text: AppConstants.authTerms, style: AuthStyles.legalLink),
            const TextSpan(text: AppConstants.authTermsJoiner),
            TextSpan(
              text: AppConstants.authPrivacy,
              style: AuthStyles.legalLink,
            ),
            const TextSpan(text: '\n${AppConstants.authTermsSuffix}'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
