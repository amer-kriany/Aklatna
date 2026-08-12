import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';

class MarkOutForDeliveryUseCase {
  final OrderRepository repository;

  MarkOutForDeliveryUseCase({
    required this.repository,
  });

  Future<void> call({
    required String orderId,
  }) {
    return repository.markOutForDelivery(
      orderId: orderId,
    );
  }
}