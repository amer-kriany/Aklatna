import 'package:aklatna/features/orders/data/repositories/order_repository_impl.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';

class GetCustomerOrdersUseCase {
  final OrderRepositoryImpl orderRepositoryImpl;
  GetCustomerOrdersUseCase({required this.orderRepositoryImpl});
  Future<List<OrderEntity>> call(String customerId) {
    return orderRepositoryImpl.customerOrders(customerId) ;
  }
}


