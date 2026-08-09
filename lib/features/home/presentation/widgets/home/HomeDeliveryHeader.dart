import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class HomeDeliveryHeader extends StatelessWidget {
  final String addressLabel;
  final String? avatarUrl;

  final VoidCallback onAvatarTap;
  final VoidCallback onAddressTap;

  final LayerLink profileLayerLink;
  final Animation<double> profilePulseAnimation;

  const HomeDeliveryHeader({
    super.key,
    required this.addressLabel,
    required this.onAvatarTap,
    required this.onAddressTap,
    required this.profileLayerLink,
    required this.profilePulseAnimation,
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
                    Icon(Icons.location_on, size: AppSizes.iconSm, color: AppColors.primary),
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
                    const SizedBox(width: AppSpacing.xxs),
                    Icon(Icons.keyboard_arrow_down_rounded, size: AppSizes.iconSm, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ),
        CompositedTransformTarget(
  link: profileLayerLink,

  child: GestureDetector(
    onTap: onAvatarTap,

    child: AnimatedBuilder(
      animation: profilePulseAnimation,

      builder: (context, child) {
        return Transform.scale(
          scale: profilePulseAnimation.value,
          child: child,
        );
      },

      child: Container(
        padding: const EdgeInsets.all(2),

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: CircleAvatar(
          radius: AppSizes.avatarMd / 2,

          backgroundColor: AppColors.background,

          child: ClipOval(
            child: SizedBox(
              width: AppSizes.avatarMd - 4,
              height: AppSizes.avatarMd - 4,

              child: avatarUrl != null
                  ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,

                      errorBuilder: (c, e, s) {
                        return Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: AppSizes.iconLg,
                        );
                      },
                    )
                  : Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: AppSizes.iconLg,
                    ),
            ),
          ),
        ),
      ),
    ),
  ),
),
      ],
    );
  }
}