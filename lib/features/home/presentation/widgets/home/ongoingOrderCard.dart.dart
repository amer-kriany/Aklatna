import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:aklatna/features/orders/order_type.dart';
import 'package:flutter/material.dart';

class OngoingOrderCard extends StatelessWidget {
  const OngoingOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final OrderEntity order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final estimatedTime = order.estimatedPreparationTime;

    // BUGFIX: original condition had a precedence bug —
    // `a || b && c && d` parses as `a || (b && c && d)`, so when
    // status was `preparing` with a null estimatedTime, this still
    // evaluated true and crashed on `estimatedTime!` below. Explicit
    // parens fix it.
    final showPredictedTime =
        (order.orderStatus == OrderStatus.preparing ||
        order.orderStatus == OrderStatus.outForDelivery||
            order.orderStatus == OrderStatus.ready) &&
        estimatedTime != null &&
        estimatedTime > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    _statusIcon(order.orderStatus),
                    color: AppColors.primary,
                    size: AppSizes.iconMd,
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.businessName ?? 'المطعم',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      Text(
                        _statusText(order.orderStatus),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_left,
                  color: AppColors.textSecondary,
                ),
              ],
            ),

            // Predicted ready clock time
            if (showPredictedTime) ...[
              const SizedBox(height: AppSpacing.md),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Text(
                      _formatReadyTime(estimatedTime),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      'الوقت المتوقع',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.xs),

                    const Icon(
                      Icons.schedule_rounded,
                      size: 19,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatReadyTime(int minutes) {
  final baseTime = order.createdAt ?? DateTime.now();
  final readyTime = baseTime.add(Duration(minutes: minutes));

  final hour = readyTime.hour.toString().padLeft(2, '0');
  final minute = readyTime.minute.toString().padLeft(2, '0');

  return '$hour:$minute';
}

  String _statusText(OrderStatus status) {
  final isPickup = order.orderType == OrderType.pickup;

  switch (status) {
    case OrderStatus.pending:
      return 'بانتظار المطعم';

    case OrderStatus.preparing:
      return 'جاري تحضير طلبك';

    case OrderStatus.ready:
      return isPickup ? 'طلبك جاهز للاستلام' : 'طلبك جاهز';

    case OrderStatus.outForDelivery:
      return 'الطلب مع السائق';

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

      case OrderStatus.outForDelivery:
        return Icons.delivery_dining_rounded;

      case OrderStatus.completed:
        return Icons.check_circle_rounded;

      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}