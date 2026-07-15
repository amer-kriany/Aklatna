import 'package:flutter/material.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_style.dart';
import '../../../../../core/theme/app_colors.dart';

class CartDeliveryAddressSection extends StatelessWidget {
  const CartDeliveryAddressSection({
    super.key,
    required this.address,
    required this.onEdit,
  });

  final String address;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('عنوان التوصيل ', style: AppTextStyles.regularLarge),
            GestureDetector(
              onTap: onEdit,
              child: Text(
                'تعديل',
                style: AppTextStyles.regularMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(address, style: AppTextStyles.regularMedium),
        ),
      ],
    );
  }
}
