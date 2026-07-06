import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeDeliveryHeader extends StatelessWidget {
  final String addressLabel;
  final String? avatarUrl;
  final VoidCallback onAvatarTap;
  final VoidCallback onAddressTap;

  const HomeDeliveryHeader({
    super.key,
    required this.addressLabel,
    required this.onAvatarTap,
    required this.onAddressTap,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onAddressTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التوصيل إلى',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: AppSizes.iconSm,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Flexible(
                      child: Text(
                        addressLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: onAvatarTap,
          child: CircleAvatar(
            radius: AppSizes.avatarSm / 2,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(Icons.person, color: AppColors.primary)
                : null,
          ),
        ),
      ],
    );
  }
}