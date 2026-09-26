
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

  /// Whether the business is currently open.
  final bool isOpen;

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
    this.isOpen = false,
    this.compact = false,
  });

  // ==========================================================================
  // FAVORITE
  // ==========================================================================

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

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final hasSubtitle =
        subtitle != null && subtitle!.trim().isNotEmpty;

    final hasStatus =
        statusText != null && statusText!.trim().isNotEmpty;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: AppColors.border.withOpacity(0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==========================================================
                  // IMAGE
                  // ==========================================================

                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImage(),

                        // Slight bottom gradient
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: compact ? 38 : 52,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.32),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ====================================================
                        // STATUS
                        // ====================================================

                        if (hasStatus)
                          Positioned(
                            top: compact ? 7 : 10,
                            left: compact ? 7 : 10,
                            child: _buildStatusBadge(),
                          ),

                        // ====================================================
                        // FAVORITE
                        // ====================================================

                        Positioned(
                          top: compact ? 7 : 10,
                          right: compact ? 7 : 10,
                          child: _buildFavoriteButton(context),
                        ),

                        // ====================================================
                        // RATING
                        // ====================================================

                        if (rating != null)
                          Positioned(
                            bottom: compact ? 7 : 10,
                            right: compact ? 7 : 10,
                            child: _buildRating(),
                          ),
                      ],
                    ),
                  ),

                  // ==========================================================
                  // INFORMATION
                  // ==========================================================

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 9 : AppSpacing.sm,
                      compact ? 7 : AppSpacing.sm,
                      compact ? 9 : AppSpacing.sm,
                      compact ? 9 : AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ----------------------------------------------------
                        // BUSINESS NAME
                        // ----------------------------------------------------

                        Text(
                          businessName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: compact ? 13 : 16,
                          ),
                        ),

                        // ----------------------------------------------------
                        // SUBTITLE
                        // ----------------------------------------------------

                        if (hasSubtitle) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppTextStyles.regularSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: compact ? 10 : 12,
                            ),
                          ),
                        ],

                        // Small bottom breathing room
                        if (!hasSubtitle)
                          SizedBox(
                            height: compact ? 3 : 5,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
        color: AppColors.primaryLight,
        alignment: Alignment.center,
        child: Icon(
          Icons.storefront_rounded,
          color: AppColors.primary,
          size: compact ? 28 : 40,
        ),
      );
    }

    return Image.network(
      coverUrl!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return Container(
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
          color: AppColors.surfaceVariant,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondary,
            size: compact ? 22 : 30,
          ),
        );
      },
    );
  }

  // ==========================================================================
  // STATUS BADGE
  // ==========================================================================

  Widget _buildStatusBadge() {
    final backgroundColor = isOpen
        ? Colors.green.withOpacity(0.94)
        : Colors.red.withOpacity(0.94);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          AppRadius.full,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 5 : 6,
            height: compact ? 5 : 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            statusText!,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 9 : 10.5,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // RATING
  // ==========================================================================

  Widget _buildRating() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(
          AppRadius.full,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: compact ? 11 : 14,
            color: AppColors.warning,
          ),
          const SizedBox(width: 3),
          Text(
            rating!.toStringAsFixed(1),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 9 : 11,
            ),
          ),
          if (ratingCount != null) ...[
            const SizedBox(width: 2),
            Text(
              '($ratingCount)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: compact ? 8.5 : 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // FAVORITE BUTTON
  // ==========================================================================

  Widget _buildFavoriteButton(BuildContext context) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favoriteState) {
        final isFavorite =
            favoriteState is FavoriteLoaded &&
            favoriteState.favoriteIds.contains(
              businessId,
            );

        final size = compact ? 28.0 : 36.0;

        return Material(
          color: Colors.white.withOpacity(0.94),
          shape: const CircleBorder(),
          elevation: 1,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _onToggleFavorite(context),
            child: SizedBox(
              width: size,
              height: size,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(isFavorite),
                  color: isFavorite
                      ? AppColors.primary
                      : Colors.black87,
                  size: compact ? 15 : 19,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
