import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:aklatna/core/constants/app_assets.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_styles.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({required this.label, this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AuthStyles.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          disabledBackgroundColor: AppColors.primaryLight,
          disabledForegroundColor: Colors.white,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthStyles.fieldRadius),
          ),
          textStyle: AuthStyles.button,
        ),
        icon: SvgPicture.asset(AppAssets.entry, width: 18, height: 18),
        label: Text(label),
      ),
    );
  }
}
