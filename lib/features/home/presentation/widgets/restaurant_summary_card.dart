import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:aklatna/core/constants/app_assets.dart';
import 'package:aklatna/core/theme/app_colors.dart';

class RestaurantSummaryCard extends StatelessWidget {
  const RestaurantSummaryCard({required this.restaurant, super.key});

  final RestaurantSummary restaurant;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 254,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _RestaurantImage(restaurant: restaurant),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _OpenBadge(isOpen: restaurant.isOpen),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _RatingPill(rating: restaurant.rating),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        restaurant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 28 / 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      restaurant.deliveryTime,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      AppAssets.clock,
                      width: 15,
                      height: 15,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        restaurant.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantImage extends StatelessWidget {
  const _RestaurantImage({required this.restaurant});

  final RestaurantSummary restaurant;

  @override
  Widget build(BuildContext context) {
    if (restaurant.imageUrl != null && restaurant.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: restaurant.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            const ColoredBox(color: AppColors.tagBackground),
        errorWidget: (_, __, ___) => const _ImageFallback(),
      );
    }

    if (restaurant.imageAsset != null) {
      return Image.asset(
        restaurant.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ImageFallback(),
      );
    }

    return const _ImageFallback();
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.tagBackground,
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 42,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  const _OpenBadge({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            Text(
              isOpen ? 'مفتوح' : 'مغلق',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isOpen ? AppColors.openBadge : AppColors.closedBadge,
              ),
            ),
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 4,
              backgroundColor: isOpen
                  ? AppColors.openBadge
                  : AppColors.closedBadge,
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.tagBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rating,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 4),
          SvgPicture.asset(
            AppAssets.star,
            width: 12,
            height: 12,
            colorFilter: const ColorFilter.mode(
              AppColors.primaryDark,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}

class RestaurantSummary {
  const RestaurantSummary({
    required this.name,
    required this.description,
    required this.rating,
    required this.deliveryTime,
    required this.isOpen,
    this.imageUrl,
    this.imageAsset,
  });

  final String name;
  final String description;
  final String rating;
  final String deliveryTime;
  final bool isOpen;
  final String? imageUrl;
  final String? imageAsset;
}
