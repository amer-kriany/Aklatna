import 'package:flutter/material.dart';

import 'package:aklatna/core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderIconButton(icon: Icons.notifications_none_rounded, onTap: () {}),
        const SizedBox(width: 8),
        _HeaderIconButton(icon: Icons.favorite_border_rounded, onTap: () {}),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
              'أكلاتنا',
              style: TextStyle(
                fontSize: 22,
                height: 28 / 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4),
                Text(
                  'داريا',
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }
}
