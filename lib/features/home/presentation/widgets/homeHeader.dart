import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';

/// Simplified Home header — replaces Figma's "Delivery to / Jakarta" +
/// personalized greeting, which don't apply here (no location-based
/// search, no per-user greeting requirement in your PRD).
///
/// No notification icon either — FCM/push notifications were dropped
/// entirely per your PRD (dashboard is realtime-only), so a bell icon
/// here would imply an in-app notification feature that doesn't exist.
/// Just the app identity.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Align(
        alignment: Alignment.centerRight, // leading edge in RTL
        child: Column(
          spacing: 22,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Delivery to", style: AppTextStyles.h4),
                    Row(
                      spacing: 4,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.location,
                        ),
                        Text("data", style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  // user profile Image  later
                  child: Image.asset(
                    "assets/images/profile.jpg",
                    width: 45,
                    height: 45,
                  ),
                ),
              ],
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Hey Reisee, ",
                    style: AppTextStyles.regularLarge,
                  ),
                  TextSpan(text: agreeting(), style: AppTextStyles.buttonLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String agreeting() {
    final time = DateTime.now().hour;
    if (time >= 5 && time < 12) {
      return "Good Morning!";
    } else if (time >= 12 && time < 17) {
      return "Good Afternoon!";
    } else {
      return "Good Evening";
    }
  }
}
