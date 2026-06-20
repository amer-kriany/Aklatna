import 'package:flutter/material.dart';

import 'package:aklatna/core/theme/app_colors.dart';

class TrendingFoodCard extends StatelessWidget {
  const TrendingFoodCard({required this.item, super.key});

  final TrendingFoodItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.asset(
              item.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: AppColors.tagBackground,
                child: Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.price,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrendingFoodItem {
  const TrendingFoodItem({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.price,
  });

  final String title;
  final String subtitle;
  final String imageAsset;
  final String price;
}
