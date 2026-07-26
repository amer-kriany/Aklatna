import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:flutter/material.dart';

/// Search result card — Bloc-blind, no onTap param (page layer wraps
/// this with GestureDetector/InkWell for navigation).
class SearchResultCard extends StatelessWidget {
  const SearchResultCard({super.key, required this.business});

  final BusinessEntity business;

  bool get _hasValidCoverUrl {
    final coverUrl = business.coverUrl?.trim() ?? '';
    final uri = Uri.tryParse(coverUrl);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: _hasValidCoverUrl
              ? Image.network(
                  business.coverUrl!.trim(),
                  width: AppSizes.avatarLg,
                  height: AppSizes.avatarLg,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: AppSizes.avatarLg,
                  height: AppSizes.avatarLg,
                  color: AppColors.surface,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.storefront,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(business.nameAr, style: AppTextStyles.h4),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                business.adress,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}