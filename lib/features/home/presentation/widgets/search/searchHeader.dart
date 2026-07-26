import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Aklatna (أكلتنا) — Search page header: greeting title + profile avatar.
///
/// Bloc-blind: [imageUrl] is passed in by the page, which reads it from
/// ProfileEntity via BlocBuilder. This widget doesn't know ProfileEntity
/// or ProfileBloc exist.
class SearchHeader extends StatelessWidget {
  final String? category;
  const SearchHeader({super.key, required this.imageUrl, this.category});

  /// Nullable — falls back to a person icon if the profile has no photo yet.
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 115),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.h2,
              children: [
                TextSpan(text: category != null ? "قريبة عليك" : 'يلا نطلب '),
                TextSpan(
                  text: category ?? 'أكل',
                  style: AppTextStyles.h2.copyWith(color: AppColors.greeting),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _Avatar(imageUrl: imageUrl),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    const size = AppSizes.avatarMd;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.surfaceVariant,
        child: const Icon(
          Icons.person_rounded,
          color: AppColors.textSecondary,
          size: AppSizes.iconLg,
        ),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.surfaceVariant,
      backgroundImage: NetworkImage(imageUrl!),
    );
  }
}
