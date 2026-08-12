import 'dart:ui';

import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/orders/orderStatus.dart';

/// Single source of truth for how an OrderStatus is labeled/colored in
/// driver-facing UI. Was previously duplicated (and drifting) across
/// AvailableOrderCard, _DriverOrderCard, and DriverOrderDetailsPage.
String orderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'قيد الانتظار';
    case OrderStatus.preparing:
      return 'قيد التحضير';
    case OrderStatus.ready:
      return 'جاهز للاستلام';
    case OrderStatus.outForDelivery:
      return 'في الطريق';
    case OrderStatus.completed:
      return 'تم التسليم';
    case OrderStatus.cancelled:
      return 'ملغي';
  }
}

Color orderStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return AppColors.statusPending;
    case OrderStatus.preparing:
      return AppColors.statusPreparing;
    case OrderStatus.ready:
      return AppColors.statusReady;
    case OrderStatus.outForDelivery:
      return AppColors.statusOutForDelivery;
    case OrderStatus.completed:
      return AppColors.statusCompleted;
    case OrderStatus.cancelled:
      return AppColors.statusCancelled;
  }
}