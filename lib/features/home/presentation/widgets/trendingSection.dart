import 'package:aklatna/features/home/presentation/widgets/businessCard.dart';
import 'package:aklatna/features/home/presentation/widgets/sectionHeader.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';


/// Trending section — "most orders in last 7 days" per your PRD.
/// TODO: connect to HomeBloc. Replace [items] with real trending
/// businesses (sorted server-side or client-side by order count).
class TrendingSection extends StatelessWidget {
  const TrendingSection({
    super.key,
    required this.items,
    this.onSeeAll,
    this.onCardTap,
  });

  final List<TrendingCardData> items;
  final VoidCallback? onSeeAll;
  final ValueChanged<String>? onCardTap; // callback receives businessId

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'الأكثر طلباً', onSeeAll: onSeeAll),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = items[index];
              return BusinessCard(
                name: item.name,
                typeLabel: item.typeLabel,
                imageUrl: item.imageUrl,
                isOpen: item.isOpen,
                onTap: () => onCardTap?.call(item.businessId),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Plain data holder for one trending card.
/// TODO: replace with your real BusinessEntity when wiring the Bloc —
/// this exists so the widget doesn't depend on your domain layer.
class TrendingCardData {
  const TrendingCardData({
    required this.businessId,
    required this.name,
    required this.typeLabel,
    required this.imageUrl,
    required this.isOpen,
  });

  final String businessId;
  final String name;
  final String typeLabel;
  final String imageUrl;
  final bool isOpen;
}