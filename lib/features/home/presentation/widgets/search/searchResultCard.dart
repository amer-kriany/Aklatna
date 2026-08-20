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

  String _shortAddress(String fullAddress) {
    final parts = fullAddress
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'داريا';

    final firstPart = parts.first;

    if (firstPart.contains('داريا')) {
      return 'داريا';
    }

    return '$firstPart, داريا';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // IMAGE + STATUS DOT
          // ============================================================
          Stack(
            clipBehavior: Clip.none,
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
                          Icons.storefront_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: business.isOpen
                        ? AppColors.success
                        : AppColors.textHint,
                    border: Border.all(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: AppSpacing.sm),

          // ============================================================
          // TEXT INFO
          // ============================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business.nameAr,
                  style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        _shortAddress(business.adress),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            business.rating.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      business.isOpen ? 'مفتوح الآن' : 'مغلق الآن',
                      style: AppTextStyles.caption.copyWith(
                        color: business.isOpen
                            ? AppColors.success
                            : AppColors.textHint,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}