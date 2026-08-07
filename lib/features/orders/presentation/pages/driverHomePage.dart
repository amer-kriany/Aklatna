import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aklatna/features/orders/presentation/widgets/availableOrderCard.dart';
import 'package:aklatna/features/orders/presentation/widgets/orderHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  String get _driverId => Supabase.instance.client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();

    context.read<OrderBloc>().add(
      GetAvailableOrdersEvent(driverId: _driverId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الطلبات المتاحة"),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AvailableOrdersLoaded) {
            return Column(
              children: [
                EarningsHeader(total: state.totalEarnings),
                Expanded(
                  child: state.orders.isEmpty
                      ? const Center(
                          child: Text("لا يوجد طلبات حالياً"),
                        )
                      : ListView.builder(
                          itemCount: state.orders.length,
                          itemBuilder: (_, index) {
                            return AvailableOrderCard(
                              order: state.orders[index],
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}