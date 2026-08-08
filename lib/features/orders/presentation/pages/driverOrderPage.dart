import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:aklatna/features/orders/presentation/pages/driverOrderDetailsPage.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aklatna/features/orders/presentation/widgets/orderStatusUi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverOrdersPage extends StatefulWidget {
  const DriverOrdersPage({super.key});

  @override
  State<DriverOrdersPage> createState() => _DriverOrdersPageState();
}

class _DriverOrdersPageState extends State<DriverOrdersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String get _driverId => Supabase.instance.client.auth.currentUser!.id;

  Set<String> _lastOngoingIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetch();

    final businessBloc = context.read<BusinessBloc>();
    if (businessBloc.state is! BusinessFetched) {
      businessBloc.add(GetBusinesses());
    }
  }

  void _fetch() {
    context.read<OrderBloc>().add(GetDriverOrdersEvent(driverId: _driverId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('توصيلاتي', style: AppTextStyles.h4),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'جارية'), Tab(text: 'السجل')],
          ),
        ),
        body: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is! DriverOrdersFetched) return;

            final nowOngoingIds = state.orders
                .where((o) => o.orderStatus.isOngoing)
                .map((o) => o.id!)
                .toSet();

            // An order that WAS in our ongoing set last time but is now
            // gone from it, and specifically landed on cancelled (not
            // completed), just got cancelled out from under the driver
            // -- e.g. the restaurant cancelled it, or it hit the 20-min
            // auto-cancel. Surface it instead of letting it silently
            // vanish from "جارية".
            final droppedIds = _lastOngoingIds.difference(nowOngoingIds);
            if (droppedIds.isNotEmpty) {
              final justCancelled = state.orders.where(
                (o) => droppedIds.contains(o.id) &&
                    o.orderStatus == OrderStatus.cancelled,
              );

              if (justCancelled.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إلغاء أحد طلباتك')),
                );
              }
            }

            _lastOngoingIds = nowOngoingIds;
          },
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is! DriverOrdersFetched) {
              return const SizedBox();
            }

            final ongoing =
                state.orders.where((o) => o.orderStatus.isOngoing).toList();
            final history =
                state.orders.where((o) => o.orderStatus.isHistory).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _list(ongoing, 'لا توجد توصيلات جارية'),
                _list(history, 'لا يوجد سجل توصيلات'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _list(List<OrderEntity> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: AppTextStyles.regularMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      itemCount: orders.length,
      itemBuilder: (_, i) => _DriverOrderCard(order: orders[i]),
    );
  }
}

class _DriverOrderCard extends StatelessWidget {
  const _DriverOrderCard({required this.order});

  final OrderEntity order;
  String get _driverId => Supabase.instance.client.auth.currentUser!.id;

  @override
  Widget build(BuildContext context) {
    final statusColor = orderStatusColor(order.orderStatus);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: order.orderStatus.isHistory
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DriverOrderDetailsPage(order: order),
                    ),
                  );
                },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        order.businessName ?? '',
                        style: AppTextStyles.h4,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: statusColor.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        orderStatusLabel(order.orderStatus),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: AppSizes.iconSm,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Text(
                        order.deliveryAddress ?? '',
                        style: AppTextStyles.regularSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'رسوم التوصيل: ${order.deliveryFee} ل.س',
                  style: AppTextStyles.regularSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _actionButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Order status here is one of: ready (claimed, not picked up),
  // outForDelivery (picked up), completed/cancelled (history, no action).
  Widget _actionButton(BuildContext context) {
    if (order.orderStatus == OrderStatus.ready) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            context.read<OrderBloc>().add(
              MarkOutForDeliveryEvent(
                orderId: order.id!,
                driverId: _driverId,
              ),
            );
          },
          child: const Text('بدء التوصيل'),
        ),
      );
    }

    if (order.orderStatus == OrderStatus.outForDelivery) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            context.read<OrderBloc>().add(
              CompleteOrderEvent(
                orderId: order.id!,
                driverId: _driverId,
              ),
            );
          },
          child: const Text('تم التسليم'),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}