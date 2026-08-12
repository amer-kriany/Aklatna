import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';

class GetDriverOrdersUseCase {
  final OrderRepository repository;

  GetDriverOrdersUseCase({required this.repository});

  Future<List<OrderEntity>> call(String driverId) {
    return repository.getDriverOrders(driverId);
  }
}