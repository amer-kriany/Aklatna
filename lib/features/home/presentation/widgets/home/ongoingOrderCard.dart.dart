import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
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
   print(
  'CARD -> status=${order.orderStatus}, '
  'estimated=${order.estimatedPreparationTime}',

);
    final estimatedTime = order.estimatedPreparationTime;

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

            // Estimated preparation time
            if (order.orderStatus == OrderStatus.preparing &&
    estimatedTime != null &&
    estimatedTime > 0) ...[
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
                    const Icon(
                      Icons.schedule_rounded,
                      size: 19,
                      color: AppColors.primary,
                    ),

                    const SizedBox(width: AppSpacing.xs),

                    Text(
  'مدة التحضير المتوقعة',
  style: AppTextStyles.bodySmall.copyWith(
    color: AppColors.textSecondary,
  ),
),

                    const Spacer(),

                   Text(
  _formatPreparationTime(estimatedTime),
  style: AppTextStyles.bodySmall.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  ),
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

  String _formatPreparationTime(int minutes) {
    if (minutes < 60) {
      return '$minutes دقيقة';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours ساعة';
    }

    return '$hours ساعة و$remainingMinutes دقيقة';
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