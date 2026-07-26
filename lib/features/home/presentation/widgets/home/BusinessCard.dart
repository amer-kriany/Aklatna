import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/features/favorit/presentation/bloc/favorite_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/theme/app_colors.dart';

class BusinessCard extends StatelessWidget {
  final String businessId;
  final String businessName;
  final String? subtitle;
  final String? coverUrl;
  final double? rating;
  final int? ratingCount;

  final VoidCallback onTap;

  final double? width;
  final double height;
  final double imageAspectRatio;

  final String? statusText;
  final String? deliveryFeeText;

  /// Makes the card suitable for small horizontal lists.
  final bool compact;

  const BusinessCard({
    super.key,
    required this.businessId,
    required this.businessName,
    required this.onTap,
    this.subtitle,
    this.coverUrl,
    this.rating,
    this.ratingCount,
    this.width,
    this.height = 240,
    this.imageAspectRatio = 1.3,
    this.statusText,
    this.deliveryFeeText,
    this.compact = false,
  });

  void _onToggleFavorite(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء تسجيل الدخول لإضافة المفضلة'),
        ),
      );
      return;
    }

    context.read<FavoriteBloc>().add(
          ToggleFavoriteEvent(
            userId: userId,
            businessId: businessId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final hasSubtitle =
        subtitle != null && subtitle!.trim().isNotEmpty;

    final hasStatus =
        statusText != null && statusText!.trim().isNotEmpty;

    final hasDelivery =
        deliveryFeeText != null &&
        deliveryFeeText!.trim().isNotEmpty;

    return SizedBox(
      width: width,
      height: height,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // IMAGE
              // ============================================================
              Expanded(
                flex: compact ? 58 : 62,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _buildImage(),
                    ),

                    // Bottom gradient
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: compact ? 32 : 40,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0),
                              Colors.black.withOpacity(0.30),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Rating
                    if (rating != null)
                      Positioned(
                        left: AppSpacing.xs,
                        bottom: AppSpacing.xs,
                        child: _buildRating(),
                      ),

                    // Favorite
                    Positioned(
                      top: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: _buildFavoriteButton(context),
                    ),
                  ],
                ),
              ),

              // ============================================================
              // INFORMATION
              // ============================================================
              Expanded(
                flex: compact ? 42 : 38,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 8 : AppSpacing.sm,
                    compact ? 6 : AppSpacing.xs,
                    compact ? 8 : AppSpacing.sm,
                    compact ? 7 : AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business name + subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            businessName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: compact ? 15 : null,
                            ),
                          ),

                          if (hasSubtitle) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.regularSmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: compact ? 10 : null,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const Spacer(),

                      // ====================================================
                      // STATUS + DELIVERY
                      // ====================================================
                      if (hasStatus || hasDelivery)
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: compact ? 4 : 6,
                            runSpacing: 4,
                            children: [
                              if (hasStatus)
                                _buildPill(
                                  text: statusText!,
                                  backgroundColor:
                                      AppColors.primaryLight,
                                  foregroundColor:
                                      AppColors.primary,
                                ),

                              if (hasDelivery)
                                _buildPill(
                                  text: deliveryFeeText!,
                                  backgroundColor:
                                      AppColors.surfaceVariant,
                                  foregroundColor:
                                      AppColors.textPrimary,
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // IMAGE
  // ==========================================================================

  Widget _buildImage() {
    if (coverUrl == null || coverUrl!.isEmpty) {
      return Container(
        color: AppColors.primaryLight,
        alignment: Alignment.center,
        child: Icon(
          Icons.storefront_rounded,
          color: AppColors.primary,
          size: compact
              ? AppSizes.iconXl
              : AppSizes.iconXl * 1.4,
        ),
      );
    }

    return Image.network(
      coverUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return Container(
          color: AppColors.surfaceVariant,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.surfaceVariant,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondary,
            size: compact
                ? AppSizes.iconLg
                : AppSizes.iconXl,
          ),
        );
      },
    );
  }

  // ==========================================================================
  // RATING
  // ==========================================================================

  Widget _buildRating() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : AppSpacing.xs,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: compact ? 11 : 13,
            color: AppColors.warning,
          ),

          const SizedBox(width: 3),

          Text(
            rating!.toStringAsFixed(1),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 9 : null,
            ),
          ),

          if (ratingCount != null) ...[
            const SizedBox(width: 2),
            Text(
              '($ratingCount)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: compact ? 9 : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // FAVORITE
  // ==========================================================================

  Widget _buildFavoriteButton(BuildContext context) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favoriteState) {
        final isFavorite =
            favoriteState is FavoriteLoaded &&
            favoriteState.favoriteIds.contains(businessId);

        final size = compact ? 30.0 : 32.0;

        return Material(
          color: Colors.white.withOpacity(0.9),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _onToggleFavorite(context),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite
                    ? AppColors.primary
                    : Colors.black87,
                size: compact ? 16 : 17,
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // CHIP
  // ==========================================================================

  Widget _buildPill({
    required String text,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          AppRadius.full,
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 9 : null,
        ),
      ),
    );
  }
}