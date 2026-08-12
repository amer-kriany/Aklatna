import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aklatna/features/orders/presentation/widgets/availableOrderCard.dart';
import 'package:aklatna/features/orders/presentation/widgets/earningHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key, this.onOrderAccepted});

  final VoidCallback? onOrderAccepted;

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

    // AvailableOrderCard looks up restaurant address via BusinessBloc,
    // but nothing on the driver side ever populates it -- only the
    // customer HomePage fires GetBusinesses(). Without this, the
    // address silently never shows (guarded by a null check, no error).
    final businessBloc = context.read<BusinessBloc>();
    if (businessBloc.state is! BusinessFetched) {
      businessBloc.add(GetBusinesses());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الطلبات المتاحة"),
      ),
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          // One-shot signal fired when accept fails (e.g. another
          // driver already claimed it). Doesn't affect the list UI --
          // OrderBloc re-emits AvailableOrdersLoaded right after this.
          if (state is OrderAcceptFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is OrderFailure) {
              return Center(child: Text('خطأ: ${state.error}'));
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
                                onAccepted: widget.onOrderAccepted,
                                isDisabled: state.hasActiveDelivery,
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
      ),
    );
  }
}