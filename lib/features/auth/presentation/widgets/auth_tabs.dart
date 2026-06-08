import 'package:flutter/material.dart';

import 'package:aklatna/core/constants/app_constants.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_styles.dart';

class AuthTabs extends StatelessWidget {
  const AuthTabs({required this.activeTab, required this.onChanged, super.key});

  final AuthTab activeTab;
  final ValueChanged<AuthTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AuthTabButton(
              label: AppConstants.authSignUpTab,
              isActive: activeTab == AuthTab.signUp,
              onPressed: () => onChanged(AuthTab.signUp),
            ),
          ),
          Expanded(
            child: _AuthTabButton(
              label: AppConstants.authSignInTab,
              isActive: activeTab == AuthTab.signIn,
              onPressed: () => onChanged(AuthTab.signIn),
            ),
          ),
        ],
      ),
    );
  }
}

enum AuthTab { signIn, signUp }

class _AuthTabButton extends StatelessWidget {
  const _AuthTabButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(34),
        padding: EdgeInsets.zero,
        foregroundColor: isActive ? AppColors.primaryDark : AppColors.textMuted,
        shape: const RoundedRectangleBorder(),
      ),
      child: Container(
        width: double.infinity,
        height: 35,
        padding: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.primaryDark : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AuthStyles.tab.copyWith(
            color: isActive ? AppColors.primaryDark : AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
