import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';

class AcceptOrderUseCase {
  final OrderRepository repository;

  AcceptOrderUseCase({
    required this.repository,
  });

  Future<void> call({
    required String orderId,
    required String driverId,
  }) {
    return repository.acceptOrder(
      orderId: orderId,
      driverId: driverId,
    );
  }
}