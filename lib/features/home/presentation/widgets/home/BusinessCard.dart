import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/features/favorit/presentation/bloc/favorite_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/skeleton.dart';

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
    this.height = 245,
    this.statusText,
    this.deliveryFeeText,
    this.compact = false,
  });

  void _onToggleFavorite(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تسجيل الدخول لإضافة المفضلة')),
      );
      return;
    }

    context.read<FavoriteBloc>().add(
      ToggleFavoriteEvent(userId: userId, businessId: businessId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final hasStatus = statusText != null && statusText!.trim().isNotEmpty;
    final hasDelivery =
        deliveryFeeText != null && deliveryFeeText!.trim().isNotEmpty;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              // ============================================================
              // IMAGE
              // ============================================================
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildImage()),

                    // Gradient Mask
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: compact ? 24 : 36,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0),
                              Colors.black.withOpacity(0.35),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Rating Badge
                    if (rating != null)
                      Positioned(
                        left: compact ? 6 : AppSpacing.xs,
                        bottom: compact ? 6 : AppSpacing.xs,
                        child: _buildRating(),
                      ),

                    // Favorite Button
                    Positioned(
                      top: compact ? 6 : AppSpacing.xs,
                      right: compact ? 6 : AppSpacing.xs,
                      child: _buildFavoriteButton(context),
                    ),
                  ],
                ),
              ),

              // ============================================================
              // INFORMATION
              // ============================================================
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 8 : AppSpacing.sm,
                  compact ? 5 : AppSpacing.xs,
                  compact ? 8 : AppSpacing.sm,
                  compact ? 7 : AppSpacing.sm,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business name
                    Text(
                      businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: compact ? 13 : 16,
                      ),
                    ),

                    // Subtitle
                    if (hasSubtitle) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.regularSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: compact ? 10 : 12,
                        ),
                      ),
                    ],

                    // Status + Delivery Pills
                    if (hasStatus || hasDelivery) ...[
                      SizedBox(height: compact ? 4 : 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        clipBehavior: Clip.none,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasStatus)
                              _buildPill(
                                text: statusText!,
                                backgroundColor: AppColors.primaryLight,
                                foregroundColor: AppColors.primary,
                              ),
                            if (hasStatus && hasDelivery)
                              SizedBox(width: compact ? 5 : 6),
                            if (hasDelivery)
                              _buildPill(
                                text: deliveryFeeText!,
                                backgroundColor: AppColors.surfaceVariant,
                                foregroundColor: AppColors.textPrimary,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
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
    if (coverUrl == null || coverUrl!.trim().isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.primaryLight,
        alignment: Alignment.center,
        child: Icon(
          Icons.storefront_rounded,
          color: AppColors.primary,
          size: compact ? 24 : 36,
        ),
      );
    }

    return Image.network(
      coverUrl!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.surfaceVariant,
          child: const Skeleton(
            width: double.infinity,
            height: double.infinity,
            radius: 0,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.surfaceVariant,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondary,
            size: compact ? 20 : 30,
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
        horizontal: compact ? 5 : AppSpacing.xs,
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
            size: compact ? 10 : 13,
            color: AppColors.warning,
          ),
          const SizedBox(width: 2),
          Text(
            rating!.toStringAsFixed(1),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 9 : 11,
            ),
          ),
          if (ratingCount != null) ...[
            const SizedBox(width: 1),
            Text(
              '($ratingCount)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: compact ? 9 : 10,
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

        final size = compact ? 24.0 : 32.0;

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
                color: isFavorite ? AppColors.primary : Colors.black87,
                size: compact ? 13 : 17,
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // PILL
  // ==========================================================================

  Widget _buildPill({
    required String text,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: AppTextStyles.caption.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 9.5 : 10.5,
        ),
      ),
    );
  }
}
