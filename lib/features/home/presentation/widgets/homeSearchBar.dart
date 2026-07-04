import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';

/// Search bar shown at the top of Home.
/// Read-only tap target by default (navigates to a Search screen)
/// — pass [onChanged] instead if you want live in-place search.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.onTap,
    this.controller,
    this.onChanged,
    this.readOnly = true,
  });

  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          style: AppTextStyles.regularMedium,
          decoration: InputDecoration(
            hintText: 'ابحث عن أطباق أو مطاعم...',
            hintStyle: AppTextStyles.hint,
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}