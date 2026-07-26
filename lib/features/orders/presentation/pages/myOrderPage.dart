import 'package:aklatna/features/orders/presentation/pages/orderDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_state.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aklatna/features/orders/presentation/widgets/orderCard.dart';
import 'package:aklatna/features/orders/presentation/widgets/orderStatusHelper.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 1,
    );

    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Fetch Orders
  // ---------------------------------------------------------------------------

  void _fetchOrders() {
    final profileState = context.read<ProfileBloc>().state;

    if (profileState is ProfileLoaded) {
      context.read<OrderBloc>().add(
            GetCustomerOrdersEvent(
              customerId: profileState.profile.id,
            ),
          );
    }
  }

  Future<void> _onRefresh() async {
    _fetchOrders();

    await context.read<OrderBloc>().stream.firstWhere(
          (state) => state is! OrderLoading,
        );
  }

  // ---------------------------------------------------------------------------
  // Open Order Details
  // ---------------------------------------------------------------------------

  void _openOrderDetails(
    BuildContext context,
    dynamic order,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsPage(
          order: order,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Text(
                  'طلباتي',
                  style: AppTextStyles.h2,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              Center(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  labelStyle: AppTextStyles.bodyMedium,
                  tabs: const [
                    Tab(text: 'السجل'),
                    Tab(text: 'جارية'),
                    Tab(text: 'مجدولة'),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ---------------------------------------------------------
                    // History
                    // ---------------------------------------------------------

                    _buildOrdersList(
                      emptyMessage: 'لا توجد طلبات في السجل',
                      filter: (o) =>
                          OrderStatusHelper.isHistory(o.orderStatus),

                      // History is NOT tappable.
                      tappable: false,
                    ),

                    // ---------------------------------------------------------
                    // Ongoing
                    // ---------------------------------------------------------

                    _buildOngoingList(),

                    // ---------------------------------------------------------
                    // Scheduled
                    // ---------------------------------------------------------

                    _buildOrdersList(
                      emptyMessage: 'لا توجد طلبات مجدولة',
                      filter: (o) =>
                          o.scheduledFor != null &&
                          o.orderStatus == OrderStatus.pending,

                      // Scheduled is NOT tappable.
                      tappable: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Generic Orders List
  // ---------------------------------------------------------------------------

  Widget _buildOrdersList({
    required String emptyMessage,
    required bool Function(dynamic) filter,
    required bool tappable,
  }) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading || state is OrderInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is OrderFailure) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Text(state.error),
                ),
              ],
            );
          }

          if (state is! CustomerOrdersFetched) {
            return const SizedBox.shrink();
          }

          final filtered = state.orders
              .where(filter)
              .toList();

          if (filtered.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Text(
                    emptyMessage,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(
              height: AppSpacing.sm,
            ),
            itemBuilder: (context, index) {
              final order = filtered[index];

              return OrderCard(
                order: order,

                // History / scheduled = no action.
                onTap: tappable
                    ? () => _openOrderDetails(
                          context,
                          order,
                        )
                    : () {},
              );
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Ongoing Orders
  // ---------------------------------------------------------------------------

  Widget _buildOngoingList() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, orderState) {
          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              final hasDraft = cartState.items.isNotEmpty;

              if (orderState is OrderLoading ||
                  orderState is OrderInitial) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (orderState is OrderFailure) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 100),
                    Center(
                      child: Text(orderState.error),
                    ),
                  ],
                );
              }

              if (orderState is! CustomerOrdersFetched) {
                return const SizedBox.shrink();
              }

              // -------------------------------------------------------------
              // Only actual ongoing orders
              // -------------------------------------------------------------

              final filtered = orderState.orders.where((o) {
                final isScheduledPending =
                    o.scheduledFor != null &&
                    o.orderStatus == OrderStatus.pending;

                return OrderStatusHelper.isOngoing(
                      o.orderStatus,
                    ) &&
                    !isScheduledPending;
              }).toList();

              if (filtered.isEmpty && !hasDraft) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  children: [
                    const SizedBox(height: 100),
                    Center(
                      child: Text(
                        'لا توجد طلبات جارية',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                );
              }

              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                itemCount: filtered.length + (hasDraft ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(
                  height: AppSpacing.sm,
                ),
                itemBuilder: (context, index) {
                  // ---------------------------------------------------------
                  // Draft cart
                  // ---------------------------------------------------------

                  if (hasDraft && index == 0) {
                    return _DraftCartCard(
                      itemCount: cartState.items.length,
                    );
                  }

                  // ---------------------------------------------------------
                  // Ongoing order
                  // ---------------------------------------------------------

                  final order = filtered[
                    index - (hasDraft ? 1 : 0)
                  ];

                  return OrderCard(
                    order: order,

                    // 🔥 ONLY ongoing orders reach this callback.
                    onTap: () {
                      _openOrderDetails(
                        context,
                        order,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// =============================================================================
// Draft Cart Card
// =============================================================================

class _DraftCartCard extends StatelessWidget {
  const _DraftCartCard({
    required this.itemCount,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/cart'),
      borderRadius: BorderRadius.circular(
        AppRadius.lg,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(
            AppRadius.lg,
          ),
          border: Border.all(
            color: AppColors.primary,
          ),
        ),
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              color: AppColors.primary,
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لديك سلة غير مكتملة',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '$itemCount عناصر',
                    style: AppTextStyles.regularSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_left,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}