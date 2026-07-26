import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/cart/presentation/widgets/checkout/CustomRadioTile.dart';
import 'package:flutter/material.dart';

class DeliveryOptionSection extends StatelessWidget {
  final String selectedOption;
  final ValueChanged<String> onOptionChanged;

  const DeliveryOptionSection({
    super.key,
    required this.selectedOption,
    required this.onOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كيف تود استلام طعامك؟',
          style: AppTextStyles.regularLarge, // Replaced hardcoded TextStyle
        ),
        const SizedBox(height: AppSpacing.md), // Replaced 20.0

        CustomRadioTile(
          title: 'توصيل',
          subtitle: 'سيتم توصيل الطلب مباشرة إلى موقعك بسرعة وأمان.',
          isSelected: selectedOption == 'توصيل',
          onTap: () => onOptionChanged('توصيل'),
        ),
        const SizedBox(height: AppSpacing.lg), // Replaced 24.0
        CustomRadioTile(
          title: 'استلام من المطعم',
          subtitle: 'استلم طلبك من المطعم دون الحاجة للانتظار طويلاً.',
          isSelected: selectedOption == 'استلام من المطعم',
          onTap: () => onOptionChanged('استلام من المطعم'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Divider(
          color: AppColors.divider, // Replaced 0xFFE5E7EB
          thickness: 1,
        ),
      ],
    );
  }
}
