import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:flutter/material.dart';

class _OngoingOrderCard extends StatelessWidget {
  const _OngoingOrderCard({
    required this.order,
    required this.onTap,
  });

  final OrderEntity order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              _statusIcon(order.orderStatus),
              color: AppColors.primary,
              size: AppSizes.iconMd,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.businessName ?? '',
                    style: AppTextStyles.bodyMedium,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    _statusText(order.orderStatus),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _statusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'بانتظار المطعم';
      case OrderStatus.preparing:
        return 'جاري تحضير طلبك';
      case OrderStatus.ready:
        return 'طلبك جاهز';
      case OrderStatus.completed:
        return 'تم إكمال الطلب';
      case OrderStatus.cancelled:
        return 'تم إلغاء الطلب';
    }
  }

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.access_time_rounded;
      case OrderStatus.preparing:
        return Icons.restaurant_rounded;
      case OrderStatus.ready:
        return Icons.inventory_2_outlined;
      case OrderStatus.completed:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}