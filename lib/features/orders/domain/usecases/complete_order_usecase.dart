import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';

class CompleteOrderUseCase {
  final OrderRepository repository;

  CompleteOrderUseCase({
    required this.repository,
  });

  Future<void> call({
    required String orderId,
  }) {
    return repository.completeOrder(
      orderId: orderId,
    );
  }
}