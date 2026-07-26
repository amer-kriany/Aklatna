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
  final double imageAspectRatio;

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
    this.imageAspectRatio = 1.3,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        width: width,
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
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: imageAspectRatio,
                  child: _buildImage(),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 40,
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
                if (rating != null)
                  Positioned(
                    left: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 13, color: AppColors.warning),
                          const SizedBox(width: 3),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (ratingCount != null) ...[
                            const SizedBox(width: 2),
                            Text(
                              '($ratingCount)',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
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
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _onToggleFavorite(context),
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Icon(
                              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFavorite ? AppColors.primary : Colors.black87,
                              size: 17,
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
              padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.xs, AppSpacing.sm, 2),
              child: Text(
                businessName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
                child: Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.regularSmall.copyWith(color: AppColors.textSecondary),
                ),
              )
            else
              const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (coverUrl == null || coverUrl!.isEmpty) {
      return Container(
        color: AppColors.primaryLight,
        alignment: Alignment.center,
        child: Icon(
          Icons.storefront_rounded,
          color: AppColors.primary,
          size: AppSizes.iconXl * 1.4,
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
}