import 'package:aklatna/features/home/presentation/widgets/businessCard.dart';
import 'package:aklatna/features/home/presentation/widgets/sectionHeader.dart';
import 'package:aklatna/features/home/presentation/widgets/trendingSection.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';


/// Open Now section — businesses currently open, computed via your
/// BusinessTimeUtils.isOpenNow() (not touched here — that logic stays
/// entirely yours). This widget just renders whatever list it's given.
/// TODO: connect to HomeBloc. Filter+pass only businesses where isOpen == true.
class OpenNowSection extends StatelessWidget {
  const OpenNowSection({
    super.key,
    required this.items,
    this.onSeeAll,
    this.onCardTap,
  });

  final List<TrendingCardData> items;
  final VoidCallback? onSeeAll;
  final ValueChanged<String>? onCardTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'مفتوح الآن', onSeeAll: onSeeAll),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return BusinessCard(
                name: item.name,
                typeLabel: item.typeLabel,
                imageUrl: item.imageUrl,
                isOpen: item.isOpen,
                width: double.infinity,
                onTap: () => onCardTap?.call(item.businessId),
              );
            },
          ),
        ),
      ],
    );
  }
}