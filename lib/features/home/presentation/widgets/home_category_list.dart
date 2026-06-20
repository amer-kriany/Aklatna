import 'dart:ui';

import 'package:aklatna/core/constants/app_assets.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class HomeCategoryList extends StatefulWidget {
  const HomeCategoryList({super.key});

  @override
  State<HomeCategoryList> createState() => _HomeCategoryListState();
}

class _HomeCategoryListState extends State<HomeCategoryList> {
  final List<_HomeCategory> _categories = [
    _HomeCategory(label: 'الكل', iconAsset: AppAssets.food),
    _HomeCategory(label: 'مطاعم', iconAsset: AppAssets.fastFood),
    _HomeCategory(label: 'مشروبات', iconAsset: AppAssets.drinks),
    _HomeCategory(label: 'مشاوي', iconAsset: AppAssets.grilled),
    _HomeCategory(label: 'حلويات', iconAsset: AppAssets.bonbon),
  ];

  int _selectedIndex = 0; // "الكل" selected by default

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) => _CategoryChip(
          category: _categories[index],
          isSelected: index == _selectedIndex,
          onTap: () => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final _HomeCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? Colors.white : AppColors.textSecondary;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.cardBorder,
        ),
        borderRadius: BorderRadius.circular(21),
      ),
      child: InkWell(
        onTap: onTap,
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
      ),
    );
  }
}

class _HomeCategory {
  _HomeCategory({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;
}