import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';

/// Replaces the Figma design's cuisine-category grid (Food/Drink/Burger/etc.)
/// which doesn't match your schema. Your `businesses.type` enum only has
/// `restaurant` and `juice_shop`, so this is a simple filter chip row instead.
enum BusinessTypeFilterOption { all, restaurant, juiceShop }

class BusinessTypeFilter extends StatelessWidget {
  const BusinessTypeFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final BusinessTypeFilterOption selected;
  final ValueChanged<BusinessTypeFilterOption> onSelected;

  static const _labels = {
    BusinessTypeFilterOption.all: 'الكل',
    BusinessTypeFilterOption.restaurant: 'مطاعم',
    BusinessTypeFilterOption.juiceShop: 'محلات عصائر',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Row(
        children: BusinessTypeFilterOption.values.map((option) {
          final isSelected = option == selected;
          return Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: GestureDetector(
              onTap: () => onSelected(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  _labels[option]!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}