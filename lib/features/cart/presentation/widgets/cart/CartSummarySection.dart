
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_style.dart';
import '../../../../../core/theme/app_colors.dart';

class CartSummarySection extends StatelessWidget {
  const CartSummarySection({
    super.key,
    required this.subTotal,
    required this.itemCount,
  });

  final double subTotal;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // TITLE
          // ============================================================

          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'ملخص الطلب',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ============================================================
          // ITEMS COUNT
          // ============================================================

          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 19,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'عدد المنتجات',
                  style: AppTextStyles.regularMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '$itemCount',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ============================================================
          // SUBTOTAL
          // ============================================================

          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 19,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'إجمالي المنتجات',
                  style: AppTextStyles.regularMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '${subTotal.toStringAsFixed(0)} ل.س',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ============================================================
          // DIVIDER
          // ============================================================

          Divider(
            height: 1,
            color: AppColors.textSecondary.withOpacity(0.12),
          ),

          const SizedBox(height: AppSpacing.md),

          // ============================================================
          // TOTAL
          // ============================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الإجمالي',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'قبل إضافة أجرة التوصيل',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${subTotal.toStringAsFixed(0)} ل.س',
                style: AppTextStyles.priceMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ============================================================
          // DELIVERY WARNING
          // ============================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: Colors.orange.withOpacity(0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 17,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'أجرة التوصيل غير مشمولة في الإجمالي، وسيتم الاتفاق عليها مع السائق.',
                    style: AppTextStyles.regularSmall.copyWith(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
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
