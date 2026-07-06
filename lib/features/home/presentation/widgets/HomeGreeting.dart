import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Greets the user by name with a time-of-day appropriate phrase.
/// Time bucket is computed from the device clock at build time - this is
/// presentation-level logic (not business logic), so it lives here rather
/// than in a core util.
class HomeGreeting extends StatelessWidget {
  final String userName;

  const HomeGreeting({
    super.key,
    required this.userName,
  });

  String get _greetingPhrase {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'صباح الخير';
    if (hour >= 12 && hour < 17) return 'نهارك سعيد';
    return 'مسا الخير';
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
        children: [
          TextSpan(text: 'هلا يا $userName، '),
          TextSpan(
            text: _greetingPhrase,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.greeting,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}