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
  final String? coverUrl;
  final double? rating;
  final int? ratingCount;
  final VoidCallback onTap;

  /// Fixed width for horizontal-list tiles (e.g. "Recommended" row).
  /// Leave null to let the card fill whatever width the parent gives it.
  final double? width;

  /// Controls image shape. Defaults to 16:9.
  final double imageAspectRatio;

  const BusinessCard({
    super.key,
    required this.businessId,
    required this.businessName,
    required this.onTap,
    this.coverUrl,
    this.rating,
    this.ratingCount,
    this.width,
    this.imageAspectRatio = 16 / 9,
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
          ToggleFavoriteEvent(
            userId: userId,
            businessId: businessId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: imageAspectRatio,
                    child: _buildImage(),
                  ),
                  // Floating Favorite Heart Button over image
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: BlocBuilder<FavoriteBloc, FavoriteState>(
                      builder: (context, favoriteState) {
                        final isFavorite = favoriteState is FavoriteLoaded &&
                            favoriteState.favoriteIds.contains(businessId);

                        return Material(
                          color: Colors.white.withOpacity(0.9),
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => _onToggleFavorite(context),
                            child: SizedBox(
                              width: 34,
                              height: 34,
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFavorite
                                    ? AppColors.primary
                                    : Colors.black87,
                                size: 18,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (rating != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      _buildRating(),
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

  Widget _buildImage() {
    if (coverUrl == null || coverUrl!.isEmpty) {
      return Container(
        color: AppColors.surfaceVariant,
        child: Icon(
          Icons.storefront_outlined,
          color: AppColors.textSecondary,
          size: AppSizes.iconXl,
        ),
      );
    }

    return Image.network(
      coverUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.surfaceVariant,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.surfaceVariant,
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondary,
            size: AppSizes.iconXl,
          ),
        );
      },
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            final filled = index < rating!.round();
            return Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              size: AppSizes.iconSm,
              color: AppColors.primary,
            );
          }),
        ),
        if (ratingCount != null) ...[
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '($ratingCount)',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}