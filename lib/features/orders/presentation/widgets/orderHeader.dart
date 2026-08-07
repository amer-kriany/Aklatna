import 'package:flutter/material.dart';

class EarningsHeader extends StatelessWidget {
  const EarningsHeader({super.key, required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          const Text('إجمالي الأرباح'),
          const SizedBox(height: 4),
          Text(
            '${total.toStringAsFixed(0)} ل.س',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}