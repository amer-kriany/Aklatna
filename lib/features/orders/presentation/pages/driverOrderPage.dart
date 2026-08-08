import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:aklatna/features/orders/presentation/pages/driverOrderDetailsPage.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';
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
          title: const Text('توصيلاتي'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'جارية'), Tab(text: 'السجل')],
          ),
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
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
      return Center(child: Text(emptyMessage));
    }

    return ListView.builder(
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
    return Card(
      margin: const EdgeInsets.all(12),
      child: InkWell(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.businessName ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(order.deliveryAddress ?? ''),
            const SizedBox(height: 8),
            Text('رسوم التوصيل: ${order.deliveryFee}'),
            const SizedBox(height: 16),
            _actionButton(context),
          ],
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