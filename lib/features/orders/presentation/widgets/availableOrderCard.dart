import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:supabase_flutter/supabase_flutter.dart';

class AvailableOrderCard extends StatelessWidget {
  const AvailableOrderCard({
    super.key,
    required this.order,
  });

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              order.businessName ?? "",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              order.deliveryAddress ?? "",
            ),

            const SizedBox(height: 8),

            Text(
              "${order.totalPrice} SYP",
            ),

            const SizedBox(height: 8),

            Text(
              "Delivery Fee : ${order.deliveryFee}",
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {

                  context.read<OrderBloc>().add(
                    AcceptOrderEvent(
                      orderId: order.id!,
                      driverId: Supabase.instance.client.auth.currentUser!.id,
                    ),
                  );

                },
                child: const Text("قبول الطلب"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}