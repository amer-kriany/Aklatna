import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class CartSummarySection extends StatelessWidget {
  const CartSummarySection({super.key, required this.subTotal});

  final double subTotal;

  // NOTE: dummy placeholders — no tax/fee or delivery-fee logic in Phase 1
  // schema (cash-only, no delivery integration). Replace once real pricing
  // rules exist.
  static const double _dummyTaxAndFees = 10000;

  double get _total => subTotal + _dummyTaxAndFees;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row('المجموع الفرعي', subTotal),
        const SizedBox(height: AppSpacing.sm),
        _row('الضريبة والرسوم', _dummyTaxAndFees),
        const SizedBox(height: AppSpacing.sm),
        _rowText('التوصيل', 'مجاني'),
        const SizedBox(height: AppSpacing.sm),
        _row('الإجمالي', _total, isTotal: true),
      ],
    );
  }

  Widget _row(String label, double value, {bool isTotal = false}) {
    final labelStyle = isTotal
        ? AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)
        : AppTextStyles.regularMedium.copyWith(color: AppColors.textSecondary);
    final valueStyle = isTotal
        ? AppTextStyles.priceMedium
        : AppTextStyles.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        // NOTE: raw numeric formatting — same open currency-formatting TODO
        // flagged elsewhere in the app.
        Text(value.toStringAsFixed(0), style: valueStyle),
      ],
    );
  }

  Widget _rowText(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.regularMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
