import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/widgets.dart';

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  final String text;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: text,
                style: const TextStyle(
                  fontSize: 15, // Bigger Footer Text
                  color: AppColors.textSecondary,
                ),
              ),
              TextSpan(
                text: ' $actionText',
                style: const TextStyle(
                  fontSize: 15, // Bigger Footer Action Text
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
