import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Recent search keywords chips. Bloc-blind — [keywords] and [onTap] come
/// from the page. Source of truth is local storage (shared_preferences),
/// not Supabase — there's no schema table for this.
class RecentKeywords extends StatelessWidget {
  const RecentKeywords({super.key, required this.keywords, required this.onTap});

  final List<String> keywords;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('عمليات بحث سابقة', style: AppTextStyles.h4),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: keywords.map((k) {
            return InkWell(
              onTap: () => onTap(k),
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(k, style: AppTextStyles.bodySmall),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}