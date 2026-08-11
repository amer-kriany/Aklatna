
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';

class FoodDetailsImage extends StatelessWidget {
  const FoodDetailsImage({
    super.key,
    this.imageUrl,
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
          // ============================================================
          // FOOD COVER IMAGE
          // ============================================================

          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppRadius.xl),
              bottomRight: Radius.circular(AppRadius.xl),
            ),
            child: Container(
              height: 300,
              width: double.infinity,
              color: AppColors.primaryLight,
              child: Hero(
                tag: imageUrl ?? '',
                child: _hasValidCoverUrl
                    ? Image.network(
                        imageUrl!,
                        width: double.infinity,
                        height: double.infinity,

                        // IMPORTANT:
                        // Cover makes the image fill the entire area.
                        // It crops the image instead of leaving empty space.
                        fit: BoxFit.cover,

                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: AppColors.primaryLight,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.storefront,
                              color: AppColors.textSecondary,
                              size: 48,
                            ),
                          );
                        },

                        loadingBuilder: (
                          context,
                          child,
                          loadingProgress,
                        ) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: AppColors.primaryLight,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: AppColors.primaryLight,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.storefront,
                          color: AppColors.textSecondary,
                          size: 48,
                        ),
                      ),
              ),
            ),
          ),

          // ============================================================
          // SLIGHT DARK OVERLAY
          // Makes the top buttons easier to see on bright images.
          // ============================================================

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.10),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                    stops: const [
                      0.0,
                      0.35,
                      1.0,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ============================================================
          // TOP BUTTONS
          // ============================================================

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BACK
                  _CircleIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: onBack,
                  ),

                  // FAVORITE
                  _CircleIconButton(
                    icon: isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    iconColor: isFavorite
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    onPressed: onFavorite,
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

// ============================================================
// CIRCLE BUTTON
// ============================================================

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
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

