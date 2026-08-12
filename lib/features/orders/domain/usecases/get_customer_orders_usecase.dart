import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';

class GetCustomerOrdersUseCase {
  final OrderRepository orderRepositoryImpl;
  GetCustomerOrdersUseCase({required this.orderRepositoryImpl});
  Future<List<OrderEntity>> call(String customerId) {
    return orderRepositoryImpl.customerOrders(customerId);
  }
}