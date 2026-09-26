
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

    final showPredictedTime =
        (order.orderStatus == OrderStatus.preparing ||
            order.orderStatus == OrderStatus.outForDelivery ||
            order.orderStatus == OrderStatus.ready) &&
        estimatedTime != null &&
        estimatedTime > 0;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Ink(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.10),
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        _statusIcon(order.orderStatus),
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.businessName ?? 'المطعم',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _statusText(order.orderStatus),
                            style: AppTextStyles.regularSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (order.orderNumber != null)
                      Text(
                        '#${order.orderNumber}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildProgress(),
                if (showPredictedTime) ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildEstimatedTime(estimatedTime),
                ],
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.07),
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'عرض تفاصيل الطلب',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


Widget _buildProgress() {
  final currentStep = _currentStep(order.orderStatus);
  const totalSteps = 4;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: List.generate(
      totalSteps * 2 - 1,
      (index) {
        if (index.isOdd) {
          final lineIndex = index ~/ 2;

          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: lineIndex < currentStep - 1
                    ? AppColors.primary
                    : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }

        final stepIndex = index ~/ 2;

        final isCompleted = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep - 1;

        return _ProgressDot(
          active: isCompleted,
          current: isCurrent,
        );
      },
    ),
  );
}


  Widget _buildEstimatedTime(int minutes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'الوقت المتوقع',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _formatReadyTime(minutes),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _timeDescription(minutes),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  int _currentStep(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.outForDelivery:
        return 4;
      case OrderStatus.completed:
        return 4;
      case OrderStatus.cancelled:
        return 0;
    }
  }

  String _formatReadyTime(int minutes) {
    final baseTime = order.createdAt ?? DateTime.now();
    final readyTime =
        baseTime.add(Duration(minutes: minutes));

    final hour =
        readyTime.hour.toString().padLeft(2, '0');

    final minute =
        readyTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _timeDescription(int minutes) {
    if (minutes <= 1) {
      return 'قريباً';
    }

    if (minutes < 60) {
      return 'خلال $minutes دقيقة';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return 'خلال $hours ساعة';
    }

    return 'خلال $hours س و $remainingMinutes د';
  }

  String _statusText(OrderStatus status) {
    final isPickup =
        order.orderType == OrderType.pickup;

    switch (status) {
      case OrderStatus.pending:
        return 'بانتظار تأكيد المطعم';

      case OrderStatus.preparing:
        return 'جاري تحضير طلبك';

      case OrderStatus.ready:
        return isPickup
            ? 'طلبك جاهز للاستلام'
            : 'طلبك جاهز';

      case OrderStatus.outForDelivery:
        return 'طلبك مع السائق';

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

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({
    required this.active,
    required this.current,
  });

  final bool active;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: current ? 13 : 9,
      height: current ? 13 : 9,
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary
            : AppColors.border,
        shape: BoxShape.circle,
        boxShadow: current
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }
}
