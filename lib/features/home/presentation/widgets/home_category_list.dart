import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:aklatna/core/constants/app_assets.dart';
import 'package:aklatna/core/theme/app_colors.dart';

class HomeCategoryList extends StatelessWidget {
  const HomeCategoryList({super.key});

  static const _categories = [
    _HomeCategory(label: 'الكل', iconAsset: AppAssets.food, isSelected: true),
    _HomeCategory(label: 'مطاعم', iconAsset: AppAssets.fastFood),
    _HomeCategory(label: 'مشروبات', iconAsset: AppAssets.drinks),
    _HomeCategory(label: 'مشاوي', iconAsset: AppAssets.grilled),
    _HomeCategory(label: 'حلويات', iconAsset: AppAssets.bonbon),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) =>
            _CategoryChip(category: _categories[index]),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final _HomeCategory category;

  @override
  Widget build(BuildContext context) {
    final foreground = category.isSelected
        ? Colors.white
        : AppColors.textSecondary;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: category.isSelected ? AppColors.primary : AppColors.surface,
        border: Border.all(
          color: category.isSelected ? AppColors.primary : AppColors.cardBorder,
        ),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            category.iconAsset,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Text(
            category.label,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCategory {
  const _HomeCategory({
    required this.label,
    required this.iconAsset,
    this.isSelected = false,
  });

  final String label;
  final String iconAsset;
  final bool isSelected;
}
