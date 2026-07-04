import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';

/// Section header used above Trending / خصومات / Open Now lists on Home.
/// e.g. SectionHeader(title: 'الأكثر طلباً', onSeeAll: () {...})
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h4),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'عرض المزيد',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}