import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class OrderStatusHelper {
  static Color colorFor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.preparing:
        return AppColors.statusPreparing;
      case OrderStatus.ready:
        return AppColors.statusReady;
      case OrderStatus.completed:
        return AppColors.statusCompleted;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  static String labelAr(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.preparing:
        return 'قيد التحضير';
      case OrderStatus.ready:
        return 'جاهز';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغى';
    }
  }

  static bool isHistory(OrderStatus status) =>
      status == OrderStatus.completed || status == OrderStatus.cancelled;

  static bool isOngoing(OrderStatus status) =>
      status == OrderStatus.pending ||
      status == OrderStatus.preparing ||
      status == OrderStatus.ready;
}