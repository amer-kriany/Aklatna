import 'package:flutter/material.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_style.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/delivery_price_utils.dart';

class CartSummarySection extends StatelessWidget {
  const CartSummarySection({
    super.key,
    required this.subTotal,
    required this.itemCount,
    this.deliveryPrice,
  });

  final double subTotal;
  final int itemCount;

  // Real distance-based delivery price, computed in CartPage via
  // DeliveryPriceUtils. Null if customer location/business location
  // is unavailable — in that case we show "غير متوفر" and DON'T add
  // anything to the total (better to under-charge visibility-wise than
  // silently charge 0 for a delivery that isn't actually free).
  final double? deliveryPrice;

  double get _total => subTotal + (deliveryPrice ?? 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rowText('عدد المنتجات', '$itemCount'),
        const SizedBox(height: AppSpacing.sm),
        _row('المجموع الفرعي', subTotal),
        const SizedBox(height: AppSpacing.sm),
        _rowText(
          'التوصيل',
          DeliveryPriceUtils.formatDeliveryPrice(deliveryPrice),
        ),
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