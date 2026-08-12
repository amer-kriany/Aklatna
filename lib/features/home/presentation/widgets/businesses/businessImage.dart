import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';



class FoodDetailsImage extends StatelessWidget {
  const FoodDetailsImage({
    super.key,
    required this.imageUrl,
    this.onBack,
    this.onFavorite,
    this.isFavorite = false,
  });

  final String? imageUrl;
  final VoidCallback? onBack;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  bool get _hasValidCoverUrl {
    final coverUrl = imageUrl ?? '';
    final uri = Uri.tryParse(coverUrl);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            height: 260,
            width: double.infinity,
            decoration: const BoxDecoration(
            
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.xl),
                bottomRight: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Center(
              child: Hero(
                tag: imageUrl ?? '',
                child: _hasValidCoverUrl
                    ? Image.network(
                        imageUrl!,
                        height: 210,
                        fit: BoxFit.contain,
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
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: onBack,
                  ),
                 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    // ignore: unused_element_parameter
    this.iconColor = AppColors.textPrimary,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: AppSizes.avatarSm + 10,
          height: AppSizes.avatarSm + 10,
          child: Icon(
            icon,
            size: AppSizes.iconMd,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}