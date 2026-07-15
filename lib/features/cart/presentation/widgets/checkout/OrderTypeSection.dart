import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/cart/presentation/widgets/checkout/CustomRadioTile.dart';
import 'package:flutter/material.dart';

class OrderTypeSection extends StatelessWidget {
  final String selectedOption;
  final ValueChanged<String> onOptionChanged;

  const OrderTypeSection({
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
          'اختر نوع الطلب',
          style: AppTextStyles.regularLarge, // Replaced hardcoded TextStyle
        ),
        const SizedBox(height: AppSpacing.md),

        CustomRadioTile(
          title: 'طلب عادي',
          subtitle: 'اطلب الطعام الآن واستمتع به فوراً دون تأخير.',
          isSelected: selectedOption == 'طلب عادي',
          onTap: () => onOptionChanged('طلب عادي'),
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomRadioTile(
          title: 'طلب مسبق',
          subtitle: 'اطلب الطعام مبكراً ليتم جدولته في الوقت الذي يناسبك.',
          isSelected: selectedOption == 'طلب مسبق',
          onTap: () => onOptionChanged('طلب مسبق'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Divider(color: AppColors.divider, thickness: 1),
      ],
    );
  }
}
