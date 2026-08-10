import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';

class GetNextScheduledOrderUseCase {
  final OrderRepository repository;

  GetNextScheduledOrderUseCase(this.repository);

  Future<OrderEntity?> call() {
    return repository.getNextScheduledOrder();
  }
}