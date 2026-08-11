import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';

class GetAvailableOrdersUseCase {
  final OrderRepository repository;

  GetAvailableOrdersUseCase({
    required this.repository, 
  });

  Future<List<OrderEntity>> call() {
    return repository.getAvailableOrders();
  }
}