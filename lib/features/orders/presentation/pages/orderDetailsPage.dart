import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:aklatna/features/orders/order_type.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({
    super.key,
    required this.order,
  });

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'تفاصيل الطلب',
            style: AppTextStyles.h4,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant + order number
                _buildOrderHeader(),

                const SizedBox(height: AppSpacing.lg),

                // Current order status
                _buildOrderStatus(),

                const SizedBox(height: AppSpacing.lg),

                // Delivery information
                _buildDeliveryInfo(),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  'تفاصيل المنتجات',
                  style: AppTextStyles.h4,
                ),

                const SizedBox(height: AppSpacing.md),

                // Items
                _buildItems(),

                const SizedBox(height: AppSpacing.lg),

                // Total
                _buildPriceSummary(),

                // Description
                if (order.description != null &&
                    order.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildDescription(),
                ],

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ORDER HEADER
  // ===========================================================================

  Widget _buildOrderHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Restaurant logo
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            clipBehavior: Clip.antiAlias,
            child: order.businessLogo != null &&
                    order.businessLogo!.isNotEmpty
                ? Image.network(
                    order.businessLogo!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return _restaurantPlaceholder();
                    },
                  )
                : _restaurantPlaceholder(),
          ),

          const SizedBox(width: AppSpacing.md),

          // Restaurant name + order number
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.businessName ?? 'المطعم',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'طلب #${order.orderNumber ?? order.id ?? '-'}',
                  style: AppTextStyles.regularSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                if (order.createdAt != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    _formatDate(order.createdAt!),
                    style: AppTextStyles.regularSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _restaurantPlaceholder() {
    return Center(
      child: Icon(
        Icons.restaurant_rounded,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }

  // ===========================================================================
  // ORDER STATUS
  // ===========================================================================

 Widget _buildOrderStatus() {
  return Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('حالة الطلب', style: AppTextStyles.h4),
        const SizedBox(height: AppSpacing.lg),
        if (order.orderStatus == OrderStatus.cancelled)
          _buildCancelledState()
        else
          _buildStatusTimeline(),
      ],
    ),
  );
}
Widget _buildCancelledState() {
  return Row(
    children: [
      Icon(Icons.cancel_rounded, color: AppColors.error, size: 28),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: Text(
          'تم إلغاء هذا الطلب',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
      ),
    ],
  );
}

  Widget _buildStatusTimeline() {
  final currentIndex = _statusIndex(order.orderStatus);

  return Column(
    children: [
      _statusStep(
        title: 'تم استلام الطلب',
        subtitle: 'تم إرسال طلبك إلى المطعم',
        stepIndex: 0,
        currentIndex: currentIndex,
        icon: Icons.receipt_long_rounded,
        isLast: false,
      ),
      _statusStep(
        title: 'جاري تحضير الطلب',
        subtitle: 'المطعم يقوم بتحضير طلبك',
        stepIndex: 1,
        currentIndex: currentIndex,
        icon: Icons.restaurant_rounded,
        isLast: false,
      ),
      _statusStep(
        title: 'الطلب جاهز',
        subtitle: order.orderType == OrderType.delivery
            ? 'طلبك جاهز للتوصيل'
            : 'طلبك جاهز للاستلام',
        stepIndex: 2,
        currentIndex: currentIndex,
        icon: Icons.inventory_2_rounded,
        isLast: false,
      ),
      _statusStep(
        title: 'تم الإكمال',
        subtitle: order.orderType == OrderType.delivery
            ? 'تم توصيل طلبك'
            : 'تم استلام طلبك',
        stepIndex: 3,
        currentIndex: currentIndex,
        icon: Icons.check_circle_rounded,
        isLast: true,
      ),
    ],
  );
}

  Widget _statusStep({
    required String title,
    required String subtitle,
    required int stepIndex,
    required int currentIndex,
    required IconData icon,
    required bool isLast,
  }) {
    final bool completed = stepIndex < currentIndex;
    final bool active = stepIndex == currentIndex;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed || active
                        ? AppColors.primary
                        : AppColors.surface,
                    border: Border.all(
                      color: completed || active
                          ? AppColors.primary
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    completed ? Icons.check_rounded : icon,
                    size: 20,
                    color: completed || active
                        ? AppColors.textOnPrimary
                        : AppColors.textSecondary,
                  ),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: completed
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 3,
                bottom: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: active || completed
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: active || completed
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: AppTextStyles.regularSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DELIVERY INFORMATION
  // ===========================================================================

  Widget _buildDeliveryInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات التوصيل',
          style: AppTextStyles.h4,
        ),

        const SizedBox(height: AppSpacing.md),

        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              if (order.deliveryAddress != null &&
                  order.deliveryAddress!.trim().isNotEmpty) ...[
                _infoRow(
                  icon: Icons.location_on_outlined,
                  title: 'عنوان التوصيل',
                  value: order.deliveryAddress!,
                ),
                const Divider(),
              ],

              _infoRow(
                icon: Icons.person_outline_rounded,
                title: 'العميل',
                value: order.customername,
              ),

              const Divider(),

              _infoRow(
                icon: Icons.phone_outlined,
                title: 'رقم الهاتف',
                value: order.customerPhone,
              ),

              const Divider(),

              _infoRow(
                icon: Icons.shopping_bag_outlined,
                title: 'نوع الطلب',
                value: _orderTypeText(order.orderType),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.regularSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ITEMS
  // ===========================================================================

  Widget _buildItems() {
    if (order.items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            'لا توجد منتجات',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: order.items.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final item = order.items[index];

          return _buildItem(item);
        },
      ),
    );
  }

  Widget _buildItem(CartItem item) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          clipBehavior: Clip.antiAlias,
          child: item.photoUrl != null && item.photoUrl!.isNotEmpty
              ? Image.network(
                  item.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return _foodPlaceholder();
                  },
                )
              : _foodPlaceholder(),
        ),

        const SizedBox(width: AppSpacing.md),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.nameAr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'الكمية: ${item.quantity}',
                style: AppTextStyles.regularSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        Text(
          '${item.price.toStringAsFixed(0)} ل.س',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _foodPlaceholder() {
    return Center(
      child: Icon(
        Icons.fastfood_rounded,
        color: AppColors.primary,
        size: 26,
      ),
    );
  }

  // ===========================================================================
  // PRICE SUMMARY
  // ===========================================================================

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'الإجمالي',
            style: AppTextStyles.h4,
          ),

          Text(
            '${order.totalPrice.toStringAsFixed(0)} ل.س',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DESCRIPTION
  // ===========================================================================

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملاحظات الطلب',
            style: AppTextStyles.h4,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            order.description!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  int _statusIndex(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 0;
    case OrderStatus.preparing:
      return 1;
    case OrderStatus.ready:
      return 2;
    case OrderStatus.completed:
      return 3;
    case OrderStatus.cancelled:
      return -1; // handled separately, see _buildOrderStatus
  }
}

  String _orderTypeText(OrderType type) {
    return type.toString().split('.').last;
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year - $hour:$minute';
  }
}